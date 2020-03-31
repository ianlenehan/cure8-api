class Types::UserType < Types::BaseObject
  field :id, String, null: false
  field :first_name, String, null: true
  field :last_name, String, null: true
  field :last_name, String, null: true
  field :name, String, null: true
  field :email, String, null: true
  field :phone, String, null: false
  field :image, String, null: false
  field :created_at, String, null: false
  field :updated_at, String, null: false
  field :contacts, [Types::ContactType], null: true
  field :notifications, Boolean, null: true
  field :notifications_new_link, Boolean, null: true
  field :notifications_new_rating, Boolean, null: true

  def name
    return '' unless object.first_name
    first = object.first_name
    last = object.last_name || ''
    first + ' ' + last
  end

  def contacts
    object.contacts
  end
end
