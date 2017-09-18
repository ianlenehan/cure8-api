module Api::V1
  class LinksController < ApplicationController

    # POST /v1/links/create
    def create_link
      if valid_token
        contacts = params[:link][:contacts]
        comment = params[:link][:comment]
        link = find_or_create_link(user, params[:link])

        create_curations(contacts, comment, link)
        if params[:link][:save_to_my_links]
          Curation.create(user_id: user.id, link_id: link.id, comment: comment)
        end

        render json: { links: user.links.reverse, status: 200 }
      else
        render json: { status: 401 }
      end
    end

    def create_link_from_web
      if valid_token
        comment = 'Saved from the web'
        link = find_or_create_link(user, params[:link])
        Curation.create(user_id: user.id, link_id: link.id, comment: comment)

        render json: { links: user.links.reverse, status: 200 }
      else
        render json: { status: 401 }
      end
    end

    def get_links
      if valid_token
        if user.links.any?
          render json: { links: user.links.reverse, status: 200 }
        else
          render json: { status: 204 }
        end
      else
        render json: { status: 401 }
      end
    end

    def archive
      if valid_token
        curation = Curation.find(params[:curation][:id])
        user = User.find(curation.user_id)
        rating = params[:curation][:rating]
        action = params[:curation][:action]

        notify_curator = notify(curation)

        if curation.update(status: action, rating: rating)
          rating_notification(curation, rating) if notify_curator
          render json: { links: user.links.reverse, status: 200 }
        end
      else
        render json: { status: 401 }
      end
    end

    private

    def user
      @user ||= db_token.user
    end

    def db_token
      @db_token ||= Token.find_by(token: params[:user][:token])
    end

    def curator
      @curator ||= User.find(link.link_owner)
    end

    def link
      curation = Curation.find(params[:curation][:id])
      @link ||= Link.find(curation.link_id)
    end

    def valid_token
      token = params[:user][:token]
      if !token.empty?
        user.tokens.include?(db_token)
      else
        false
      end
    end

    def notify(curation)
      not_rated = curation.rating == nil
      not_same_user = user.id != curator.id
      not_rated && not_same_user
    end

    # TODO refactor this method
    def create_curations(group_ids, comment, link)
      if group_ids
        group_ids.each do |group_id|
          group = Group.find(group_id)
          if group.user_id
            recipient = User.find(group.user_id)
            new_link_notification(recipient, link)
            Curation.create(user_id: group.user_id, link_id: link.id, comment: comment)
            send_sms(group.user_id, link.id)
          else
            group.members.each do |member_id|
              user_group = Group.find(member_id)
              recipient = User.find(user_group.user_id)
              new_link_notification(recipient, link)
              Curation.create(user_id: user_group.user_id, link_id: link.id, comment: comment)
              send_sms(user_group.user_id, link.id)
            end
          end
        end
      end
    end

    def send_sms(recipient_id, link_id)
      curator_id = Link.find(link_id).link_owner
      curator = User.find(curator_id)
      recipient = User.find(recipient_id)
      if !recipient.first_name
        @client = Twilio::REST::Client.new twilio[:account_sid], twilio[:auth_token]
        message = @client.account.messages.create(
        :body => "Your friend #{curator.name} has saved a link for you on cure8. Download the Cure8 app from the App Store or Google Play Store to view the link and start curating content for your friends!",
        :to => recipient.phone,
        :from => "+61429806720"
        )
      end
    end

    def new_link_notification(recipient, link)
      if recipient.notifications_new_link && recipient.push_token
        details = {
          from: user.name,
          title: link.title,
          type: 'curation'
        }
        send_notification(recipient, details)
      end
    end

    def rating_notification(curation, rating)
      if curator.notifications_new_rating && curator.push_tokens.length
        reaction = rating == 1 ? "Thumbs up" : "Thumbs down"
        link = Link.find(curation.link_id)
        details = {
          from: user.name,
          title: link.title,
          type: 'rating',
          reaction: reaction
        }
        send_notification(curator, details)
      end
    end

    def send_notification(recipient, details)
      if recipient.notifications
        recipient.push_tokens.each do |push_token|
          push_notification.publish(push_token.token, details)
        end
      end
    end

    def find_or_create_link(owner, link_params)
      url = format_url(link_params[:url])
      link = Link.find_by(link_owner: owner.id, url: url)
      return link if link

      newLink = Link.create(
        url: link_params[:url],
        link_owner: owner.id
      )
      get_link_data(newLink)
    end

    def format_url(link)
      url = link.split(' ').last
      if url.slice(0, 4) == 'http'
        url
      else
        "http://#{url}"
      end
    end

    def get_link_data(link)
      page = MetaInspector.new(link.url)
      title = page.title
      image = page.images.best
      link.update(title: title, image: image)
      link
    end

    def twilio
      {
        account_sid: Rails.application.secrets.twilio_account_sid,
        auth_token: Rails.application.secrets.twilio_auth_token
      }
    end

    def push_notification
      @push_notification ||= PushNotificationService.new
    end
  end
end
