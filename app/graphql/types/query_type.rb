module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :user, UserType, null: false do
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
    end

    def curations(status:, tag_ids:)
      if tag_ids.length > 0
        Curation.where(status: status).joins(:tags).where(tags: { id: tag_ids }).order('created_at DESC')
      else
        current_user.curations.where(status: status).order('created_at DESC')
      end
    end

    field :contacts, [Types::ContactType], null: false

    def contacts
      current_user.contacts
    end

    field :groups, [Types::GroupType], null: false

    def groups
      current_user.groups
    end

    field :tags, [Types::TagType], null: false

    def tags
      Tag.joins(:curations).where(curations: { user_id: current_user.id, status: "archived" })
    end

    private

    def current_user
      context[:current_user]
    end
  end
end
