class Types::PushTokenType < Types::BaseObject
  field :id, String, null: false
  field :token, String, null: false
  field :user_id, ID, null: false
  field :notify, Boolean, null: false
  field :notify_new_link, Boolean, null: false
  field :notify_new_rating, Boolean, null: false
  field :notify_new_message, Boolean, null: false
end