module Mutations
  class SetPushToken < Mutations::BaseMutation

    description "Sets push token for a user"
    argument :push_token, String, required: true

    field :user, Types::UserType, null: false
    field :errors, [String], null: true

    def resolve(push_token:)
      if (current_user.update(push_token: push_token))
        { app_user: current_user, errors: [] }
      else
        { errors: ["There was a problem updateing the push token"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end

  end
end