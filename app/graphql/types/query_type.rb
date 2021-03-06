module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :app_user, UserType, null: false

    def app_user
      current_user
    end

    field :user, UserType, null: true do
      argument :phone, String, required: true
    end

    def user(phone:)
      User.find_by(phone: phone)
    end

    field :users, [UserType], null: false

    def users
      User.all
    end

    field :curations, [CurationType], null: false do
      argument :status, String, required: true
      argument :tag_ids, [String], required: false
      argument :show_item_count, Int, required: true
    end

    def curations(status:, tag_ids:, show_item_count:)

      if tag_ids.length > 0
        Curation.where(status: status).joins(:tags).where(tags: { id: tag_ids }).paginate(page: 1, per_page: show_item_count).order('created_at DESC')
      else
        current_user.curations.where(status: status).paginate(page: 1, per_page: show_item_count).order('created_at DESC')
      end
    end

    field :curations_page_info, Boolean, null: false do
      argument :status, String, required: true
      argument :tag_ids, [String], required: false
      argument :show_item_count, Int, required: true
    end

    def curations_page_info(status:, tag_ids:, show_item_count:)
      if tag_ids.length > 0
        total_count = Curation.where(status: status).joins(:tags).where(tags: { id: tag_ids }).count
      else
        total_count = current_user.curations.where(status: status).count
      end
      show_item_count < total_count
    end

    field :contacts, [Types::ContactType], null: true

    def contacts
      Contact.where(user_id: current_user.id).order(:name)
    end

    field :groups, [Types::GroupType], null: true

    def groups
      Group.where(owner_id: current_user.id)
    end

    field :tags, [Types::TagType], null: true

    def tags
      Tag.joins(:curations).where(curations: { user_id: current_user.id, status: "archived" }).uniq.sort_by {|tag| tag.name}
    end

    field :activity, [ActivityType], null: true

    def activity
      # TODO paginate
      links = Link.where(link_owner: current_user.id).order('created_at desc').limit(20)
      activity = nil
      if links.length
        activity = links.map do |link|
          curations = Curation.where(link_id: link.id)
           ratings = curations.map do |curation|
            begin
              recipient = User.find(curation.user_id)
              contact = Contact.find_by(user_id: current_user.id, linked_user_id: recipient.id)
            rescue
              recipient = { name: 'Deleted User', id: 0 }.to_h
            end

            if recipient[:id] != current_user.id
              { user: recipient[:name] || contact.name, rating: curation.rating, id: recipient[:id] }
            end
          end
          { id: link.id, title: link.title, url: link.url, created_at: link.updated_at, ratings: ratings.compact }
        end
      end
      activity
    end

    field :conversations, [ConversationType], null: true

    def conversations
      # TODO paginate
      current_user.conversations.order('created_at DESC').uniq
    end

    field :push_tokens, [PushTokenType], null: true

    def push_tokens
      current_user.push_tokens
    end

    field :push_token, PushTokenType, null: false do
      argument :token, String, required: true
    end

    def push_token(token:)
      PushToken.find_by(token: token)
    end

    private

    def current_user
      context[:current_user]
    end

  end
end
