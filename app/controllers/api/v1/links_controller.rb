module Api::V1
  class LinksController < ApplicationController

    # POST /v1/links/create
    def create_link
      user = User.find(params[:user][:id])
      link = find_or_create_link(user, params[:link])
      save_to_my_links = params[:link][:save_to_my_links]

      create_curations(params[:link][:contact_id], link.id)
      if save_to_my_links
        Curation.create(user_id: user.id, link_id: link.id)
      end

      render json: { links: user.links, status: 200 }
    end

    def get_links
      puts 'params'
      puts params
      user = User.find(params[:user_id])
      puts 'any?'
      puts user.links.any?
      if user.links.any?
        puts 'rendering'
        render json: { links: user.links, status: 200 }
      else
        render json: { status: 204 }
      end
    end

    def archive
      curation = Curation.find(params[:curation][:id])
      user = User.find(curation.user_id)
      if curation.update(status: 'archived', rating: params[:curation][:rating])
        render json: { links: user.links, status: 200 }
      end
    end

    private
    def create_curations(group_id, link_id)
      # guard against id of zero
      if group_id > 0
        group = Group.find(group_id)
        if group.user_id
          Curation.create(user_id: group.user_id, link_id: link_id)
          send_sms(group.user_id, link_id)
        else
          group.members.each do |member_id|
            user_group = Group.find(member_id)
            Curation.create(user_id: user_group.user_id, link_id: link_id)
            send_sms(user_group.user_id, link_id)
          end
        end
      end
    end

    def send_sms(user_id, link_id)
      curator_id = Link.find(link_id).link_owner
      curator = User.find(curator_id)
      user = User.find(user_id)
      if !u.first_name
        @client = Twilio::REST::Client.new twilio[:account_sid], twilio[:auth_token]
        message = @client.account.messages.create(
        :body => "Your friend #{curator.name} has saved a link for you on cure8. As it's just testing you'll need the 'expo' app and Ian can give you the link.",
        :to => user.phone,
        # :from => "+15005550006"
        :from => "+61429806720"
        )
      end
    end

    def find_or_create_link(owner, link_params)
      url = format_url(link_params[:url])
      link = Link.find_by(link_owner: owner.id, url: url)
      return link if link

      newLink = Link.create(
        url: params[:link][:url],
        comment: params[:link][:comment],
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
  end
end
