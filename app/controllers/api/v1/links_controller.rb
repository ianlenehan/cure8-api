module Api::V1
  class LinksController < ApplicationController

    # POST /v1/links/create
    def create_link
      if valid_token
        contacts = params[:link][:contacts]
        comment = params[:link][:comment]
        link = find_or_create_link(user, params[:link])

        if contacts[0].class == String
          contact = User.find_or_create_by(phone: contacts[0])
          create_anon_curation(contact.id, comment, link)
        else
          create_curations(contacts, comment, link)
        end

        if params[:link][:save_to_my_links]
          Curation.create(user_id: user.id, link_id: link.id, comment: comment)
        end

        render json: { links: user.links, status: 200 }
      else
        render json: { status: 401 }
      end
    end

    def create_link_from_web
      if valid_token
        comment = 'Saved from the web'
        link = find_or_create_link(user, params[:link])
        Curation.create(user_id: user.id, link_id: link.id, comment: comment)

        render json: { links: user.links, status: 200 }
      else
        render json: { status: 401 }
      end
    end

    def create_link_from_extension
      token = params[:token]
      url = params[:url]

      if user = Token.find_by(token: token).user
        link = find_or_create_link(user, params)
        Curation.create(user_id: user.id, link_id: link.id)
      end

      render json: { message: 'posted' }, status: :ok
    end

    def get_links
      if valid_token
        if user.links.any?
          render json: { links: user.links, status: 200 }
        else
          render json: { links: random_link, status: 200 }
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

        add_tags(curation) if params[:curation][:tags]
        notify_curator = notify(curation)

        if curation.update(status: action, rating: rating)
          rating_notification(curation, rating) if notify_curator
          render json: { links: user.links, status: 200 }
        end
      else
        render json: { status: 401 }
      end
    end

    def update_tags
      if valid_token
        curation = Curation.find(params[:curation][:id])
        user = User.find(curation.user_id)

        if update_curation_tags(curation)
          render json: { links: user.links, status: 200 }
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
            Curation.create(
              user_id: group.user_id,
              curator_id: user.id,
              link_id: link.id,
              comment: comment
            )
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

    def create_anon_curation(user_id, comment, link)
      recipient = User.find(user_id)
      new_link_notification(recipient, link)
      Curation.create(
        user_id: user_id,
        curator_id: user.id,
        link_id: link.id,
        comment: comment
      )
      send_sms(user_id, link.id)
    end

    def send_sms(recipient_id, link_id)
      curator_id = Link.find(link_id).link_owner
      curator = User.find(curator_id)
      recipient = User.find(recipient_id)
      if !recipient.first_name
        @client = Twilio::REST::Client.new twilio[:account_sid], twilio[:auth_token]
        message = @client.api.account.messages.create(
        body: "Your friend #{curator.name} has saved a link for you on Cure8. Download the Cure8 app from the iOS App Store (http://apple.co/2lhMjAq) or Google Play store (https://goo.gl/mdNbxz) to view the link and start curating content for your friends!",
        to: recipient.phone,
        from: twilio_phone(recipient)
        )
      end
    end

    def new_link_notification(recipient, link)
      if recipient.notifications_new_link && recipient.push_tokens.length
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
        link = Link.find(curation.link_id)
        details = {
          from: user.name,
          title: link.title,
          type: 'rating',
          reaction: reactions(rating)
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
        url: url,
        link_owner: owner.id
      )
      get_link_data(newLink)
    end

    def format_url(link)
      if link.include?('http')
        'http' + link.split('http').last
      else
        link
      end
    end

    def get_link_data(link)
      page = MetaInspector.new(link.url)
      title = page.title
      image = page.images.best
      link.update(title: title, image: image)
      link
    end

    def add_tags(curation)
      tags = params[:curation][:tags]
      tags.each do |tag|
        tagRecord = Tag.find_or_create_by(name: tag)
        curation.tags << tagRecord unless curation.tags.include?(tagRecord)
      end
    end

    def update_curation_tags(curation)
      tags = params[:curation][:tags]
      curation.tags.clear
      tags.each do |tag|
        tagRecord = Tag.find_or_create_by(name: tag)
        curation.tags << tagRecord unless curation.tags.include?(tagRecord)
      end
    end

    def random_link
      curation = Tag.find_by(name: 'funny').curations.last
      link = Link.find(curation.link_id)
      link_for_app = {
        curation_id: curation.id,
        link_id: link.id,
        status: 'new',
        rating: nil,
        date_added: Date.today,
        url: link.url,
        url_type: link.url_type,
        title: link.title,
        image: link.image,
        comment: 'We thought we\'d add a link here for you to give you an idea of how this works. This will disappear when you add your own links. Enjoy!',
        shared_with: 1,
        tags: ['funny'],
        owner: {
          name: 'Cure8',
          phone: '',
        }
      }
      [link_for_app]
    end

    def twilio
      {
        account_sid: Rails.application.secrets.twilio_account_sid,
        auth_token: Rails.application.secrets.twilio_auth_token
      }
    end

    def twilio_phone(recipient)
      if recipient.phone.split('')[1] === '1'
        '+17608198213'
      else
        '+61429806720'
      end
    end

    def push_notification
      @push_notification ||= PushNotificationService.new
    end

    def reactions(value)
      ratingValues = {
        1 => 'Thumbs up',
        2 => 'Love this',
        3 => 'Haha!',
        4 => 'Sad',
        5 => 'Grr!!',
        0 => 'Thumbs down',
      }
      ratingValues[value]
    end
  end
end
