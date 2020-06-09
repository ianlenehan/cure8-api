module Mutations
  class CreatePushToken < Mutations::BaseMutation

    description "Creates push token for the current user"
    argument :push_token, String, required: true

    field :push_tokens, Types::PushTokenType, null: false
    field :errors, [String], null: true

    def resolve(push_token:)
      if (create_token(push_token))
        { push_tokens: current_user.push_tokens, errors: [] }
      else
        { errors: ["There was a problem updateing the push token"] }
      end
    end

    def create_token(push_token)
      current_user.push_tokens.create(token: push_token)
    end

    private

    def current_user
      context[:current_user]
    end

  end
end