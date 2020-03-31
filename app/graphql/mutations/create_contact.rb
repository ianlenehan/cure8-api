module Mutations
  class CreateContact < Mutations::BaseMutation

    description "Creates a new user contact"
    argument :name, String, required: true
    argument :phone, String, required: true

    field :contacts, [Types::ContactType], null: false
    field :errors, [String], null: true

    def resolve(name:, phone:)
      linked_user = find_or_create_contact(phone)
      if (current_user.contacts.create(linked_user_id: linked_user.id, name: name))
        contacts = current_user.contacts
        { contacts: contacts, errors: [] }
      else
        { errors: ["There was a problem creating the user"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end

    def find_or_create_contact(phone)
      User.find_or_create_by(phone: phone)
    end

    def contact_already_exists(phone)
      user.contacts.any? { |contact| contact[:phone] == phone }
    end

  end
end