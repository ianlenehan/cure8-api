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

        if curation.update(status: action, rating: rating)
          rating_notification(user, curation, rating) if notify(user, curation)
          render json: { links: user.links.reverse, status: 200 }
        end
      else
        render json: { status: 401 }
      end
    end

    private

    def user
      @user ||= get_user_from_token(params[:user][:token])
    end

    def valid_token
      @valid_token ||= user.tokens.include?(params[:user][:token])
    end

    def notify(user, curation)
      not_rated = curation.rating == nil
      not_same_user = user.id != curation.user_id
      not_rated && not_same_user
    end

    # TODO refactor this method
    def create_curations(group_ids, comment, link)
      if group_ids
        group_ids.each do |group_id|
          group = Group.find(group_id)
          if group.user_id
            user = User.find(group.user_id)
            new_link_notification(user, link)
            Curation.create(user_id: group.user_id, link_id: link.id, comment: comment)
            send_sms(group.user_id, link.id)
          else
            group.members.each do |member_id|
              user_group = Group.find(member_id)
              user = User.find(user_group.user_id)
              new_link_notification(user, link)
              Curation.create(user_id: user_group.user_id, link_id: link.id, comment: comment)
              send_sms(user_group.user_id, link.id)
            end
          end
        end
      end
    end

    def send_sms(user_id, link_id)
      curator_id = Link.find(link_id).link_owner
      curator = User.find(curator_id)
      user = User.find(user_id)
      if !user.first_name
        @client = Twilio::REST::Client.new twilio[:account_sid], twilio[:auth_token]
        message = @client.account.messages.create(
        :body => "Your friend #{curator.name} has saved a link for you on cure8. This can be accessed by first downloading 'expo client' from the App Store or Google Play Store. Once installed, open this link: https://exp.host/@ianlenehan/cure8-app",
        :to => user.phone,
        # :from => "+15005550006"
        :from => "+61429806720"
        )
      end
    end

    def new_link_notification(user, link)
      if user.notifications_new_link
        curator = User.find(link.link_owner)
        message = "#{curator.name} has curated a new link for you: '#{link.title}'"
        send_notification(user, message)
      end
    end

    def rating_notification(user, curation, rating)
      if user.notifications_new_rating
        reaction = rating == 1 ? "thumbs up" : "thumbs down"
        link = Link.find(curation.link_id)
        curator = User.find(link.link_owner)
        message = "#{reaction} from #{user.name} for #{link.title}"
        send_notification(curator, message)
      end
    end

    def send_notification(user, message)
      messages = [{
        "to": user.push_token,
        "badge": 1,
        "body:" message
        }]
      if user.notifications
        push_notification.publish(messages)
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

    def format_url(url)
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
