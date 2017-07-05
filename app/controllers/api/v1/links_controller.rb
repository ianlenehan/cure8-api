module Api::V1
  class LinksController < ApplicationController

    # POST /v1/links/create
    def create_link
      user = User.find(params[:user][:id])
      contacts = params[:link][:contacts]
      comment = params[:link][:comment]
      link = find_or_create_link(user, params[:link])
      save_to_my_links = params[:link][:save_to_my_links]

      create_curations(contacts, comment, link)
      if save_to_my_links
        new_link_notification(user, link)
        Curation.create(user_id: user.id, link_id: link.id, comment: comment)
      end

      render json: { links: user.links.reverse, status: 200 }
    end

    def get_links
      user = User.find(params[:user_id])
      if user.links.any?
        render json: { links: user.links.reverse, status: 200 }
      else
        render json: { status: 204 }
      end
    end

    def archive
      curation = Curation.find(params[:curation][:id])
      user = User.find(curation.user_id)
      rating = params[:curation][:rating]
      action = params[:curation][:action]
      
      if curation.update(status: action, rating: rating)
        rating_notification(user, curation, rating)
        render json: { links: user.links.reverse, status: 200 }
      end
    end

    private

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
        :body => "Your friend #{curator.name} has saved a link for you on cure8. As it's just testing you'll need the 'expo' app and Ian can give you the link.",
        :to => user.phone,
        # :from => "+15005550006"
        :from => "+61429806720"
        )
      end
    end

    def new_link_notification(user, link)
      curator = User.find(link.link_owner)
      message = "#{curator.name} has curated a new link for you: '#{link.title}'"
      send_notification(user, message)
    end

    def rating_notification(user, curation, rating)
      reaction = rating == 1 ? "thumbs up" : "thumbs down"
      link = Link.find(curation.link_id)
      curator = User.find(link.link_owner)
      message = "#{user.name} gave your curation about #{link.title} a #{reaction}"
      send_notification(curator, message)
    end

    def send_notification(user, message)
      exponent.publish(
        exponentPushToken: user.push_token,
        message: message,
        data: { text: message }, # Data is required, pass any arbitrary data to include with the notification
      )
    end

    def find_or_create_link(owner, link_params)
      url = format_url(link_params[:url])
      link = Link.find_by(link_owner: owner.id, url: url)
      return link if link

      newLink = Link.create(
        url: params[:link][:url],
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

    def exponent
      @exponent ||= Exponent::Push::Client.new
    end
  end
end
