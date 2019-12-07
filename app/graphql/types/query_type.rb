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

    field :curations, [CurationType], null: false

    def curations
      current_user.curations
    end

    field :contacts, [Types::ContactType], null: false

    def contacts
      current_user.contacts
    end

    private

    def current_user
      context[:current_user]
    end
  end
end
