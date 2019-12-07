module Mutations
  class DeleteContact < Mutations::BaseMutation

    description "Deletes a user contact"
    argument :id, String, required: true

    field :contacts, [Types::ContactType], null: false
    field :errors, [String], null: true

    def resolve(id:)
      if (Contact.find(id).destroy)
        contacts = current_user.contacts
        { contacts: contacts, errors: [] }
      else
        { errors: ["There was a problem deleting the contact"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end
    
  end
end