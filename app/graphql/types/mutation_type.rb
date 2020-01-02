module Types
  class MutationType < Types::BaseObject
    field :create_user, mutation: Mutations::CreateUser

    field :create_curation, mutation: Mutations::CreateCuration
    field :delete_curation, mutation: Mutations::DeleteCuration
    field :archive_curation, mutation: Mutations::ArchiveCuration

    field :create_contact, mutation: Mutations::CreateContact
    field :delete_contact, mutation: Mutations::DeleteContact
    field :create_group, mutation: Mutations::CreateGroup
    field :update_group, mutation: Mutations::UpdateGroup
    field :delete_group, mutation: Mutations::DeleteGroup
  end
end
