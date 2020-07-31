module Mutations
  class CreateCuration < Mutations::BaseMutation

    description "Creates a new curation"
    argument :url, String, required: true
    argument :comment, String, required: false
    argument :save_to_my_links, Boolean, required: false
    argument :selected_contact_ids, [String], required: false

    field :curations, [Types::CurationType], null: false
    field :errors, [String], null: true

    def resolve(url:, comment:, save_to_my_links:, selected_contact_ids:)
      if (generate_curations(url, comment, save_to_my_links, selected_contact_ids))
        { curations: current_user.curations, errors: [] }
      else
        { errors: ["There was a problem creating the curation"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end

    def generate_curations(url, comment, save_to_my_links, selected_contact_ids)
      link = find_or_create_link(url)
      if save_to_my_links
        user = current_user
        create_curation(current_user.id, link.id, comment)
      end

      selected_contact_ids.each do |contact_id|
        contact = Contact.find(contact_id)
        create_curation(contact.linked_user_id, link.id, comment)
        send_new_link_notification(contact.linked_user_id, link.title)
      end
      link
    end

    def create_curation(user_id, link_id, comment)
      Curation.create(user_id: user_id, link_id: link_id, comment: comment, curator_id: current_user.id)
    end

    def find_or_create_link(url)
      url = format_url(url)
      link = Link.find_by(link_owner: current_user.id, url: url)
      return link if link

      metadata = get_link_data(url)
      
      new_link = Link.create(
        url: url,
        link_owner: current_user.id,
        title: metadata[:title],
        image: metadata[:image]
      )

      new_link
    end

    def format_url(link)
      if link.include?('http')
        'http' + link.split('http').last
      else
        'http://' + link
      end
    end

    def get_link_data(url)
      page = nil
      title = url
      begin
        page = MetaInspector.new(url)
      rescue StandardError => e
        print "Meta Inspector Error: #{e}"
      end
      if page
        title = page.title if page.title != 'Access Denied'
        image = page.images.best
      end

      { title: title, image: image }
    end

    def send_new_link_notification(user_id, link_title)
      recipient = User.find(user_id)
      details = {
        from: current_user.name,
        title: link_title,
        type: 'curation'
      }

      recipient.push_tokens.each do |push_token|
        if push_token.notify && push_token.notify_new_link
          push_notification.publish(push_token.token, details)
        end
      end
    end

    def push_notification
      @push_notification ||= PushNotificationService.new
    end
  end
end
