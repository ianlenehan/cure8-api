class Types::CurationType < Types::BaseObject
  field :id, ID, null: false
  field :link, Types::LinkType, null: false
  field :rating, String, null: true
  field :status, String, null: false
  field :comment, String, null: true
  field :curator, Types::UserType, null: false
end
