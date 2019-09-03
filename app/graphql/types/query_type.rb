module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :user, UserType, null: false do
      argument :id, ID, required: true
    end

    def user(id:)
      User.find(id)
    end

    field :users, [UserType], null: false
    def users
      User.all
    end

    field :curations, [CurationType], null: false
    def curations
      current_user.active_curations
    end

    private

    def current_user
      context[:current_user]
    end
  end
end
