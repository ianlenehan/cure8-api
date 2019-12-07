module Mutations
  class CreateUser < Mutations::BaseMutation

    description "Creates a new user"
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :phone, String, required: true

    field :user, Types::UserType, null: false
    field :errors, [String], null: true

    def resolve(first_name:, last_name:, phone:)
      if (user = User.create(first_name: first_name, last_name: last_name, phone: phone))
        { user: user, errors: [] }
      else
        { errors: ["There was a problem creating the user"] }
      end
    end

  end
end
