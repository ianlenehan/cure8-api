module Types
  class MutationType < Types::BaseObject
    field :create_user, mutation: Mutations::CreateUser
    field :create_curation, mutation: Mutations::CreateCuration
    field :delete_curation, mutation: Mutations::DeleteCuration
    field :create_contact, mutation: Mutations::CreateContact
    field :delete_contact, mutation: Mutations::DeleteContact
  end
end
