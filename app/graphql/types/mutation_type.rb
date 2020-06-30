module Types
  class MutationType < Types::BaseObject
    field :create_user, mutation: Mutations::CreateUser
    field :toggle_setting, mutation: Mutations::ToggleSetting
    field :create_push_token, mutation: Mutations::CreatePushToken

    field :create_curation, mutation: Mutations::CreateCuration
    field :delete_curation, mutation: Mutations::DeleteCuration
    field :archive_curation, mutation: Mutations::ArchiveCuration

    field :create_contact, mutation: Mutations::CreateContact
    field :delete_contact, mutation: Mutations::DeleteContact
    field :create_group, mutation: Mutations::CreateGroup
    field :update_group, mutation: Mutations::UpdateGroup
    field :delete_group, mutation: Mutations::DeleteGroup

    field :create_conversation, mutation: Mutations::CreateConversation
    field :leave_conversation, mutation: Mutations::LeaveConversation
    field :send_message_notification, mutation: Mutations::SendMessageNotification

    field :toggle_notification, mutation: Mutations::ToggleNotification
  end
end
