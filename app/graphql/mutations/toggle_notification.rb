module Mutations
  class ToggleNotification < Mutations::BaseMutation

    description "Toggle a user notification preference"
    argument :field, String, required: true
    argument :token_id, String, required: true

    field :push_token, Types::PushTokenType, null: false
    field :errors, [String], null: true

    def resolve(token_id:, field:)
      current_token = PushToken.find(token_id)

      symbol = "#{field}".to_sym
      current_value = current_token[symbol]

      if (current_token.update_attribute(symbol, !current_value))
        { push_token: current_token, errors: [] }
      else
        { errors: ["There was a problem updating the user notification preference"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end

  end
end
