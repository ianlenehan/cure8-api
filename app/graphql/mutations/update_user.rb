module Mutations
  class UpdateUser < Mutations::BaseMutation

    description "Updates a new user"
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :phone, String, required: true

    field :user, Types::UserType, null: false
    field :errors, [String], null: true

    def resolve(first_name:, last_name:, phone:)
      user = User.find_by(phone: phone)
      if (user.update(first_name: first_name, last_name: last_name))
        { user: user, errors: [] }
      else
        { errors: ["There was a problem updating the user"] }
      end
    end

  end
end
