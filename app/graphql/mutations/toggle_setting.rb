module Mutations
  class ToggleSetting < Mutations::BaseMutation

    description "Toggle a user setting"
    argument :setting_name, String, required: true

    field :user, Types::UserType, null: false
    field :errors, [String], null: true

    def resolve(setting_name:)
      setting = setting_name.underscore
      symbol = "#{setting}".to_sym
      current_value = current_user[symbol]

      if (current_user.update_attribute(symbol, !current_value))
        { user: current_user, errors: [] }
      else
        { errors: ["There was a problem updating the user settings"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end

  end
end
