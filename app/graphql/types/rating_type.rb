class Types::RatingType < Types::BaseObject
  field :user, String, null: false
  field :rating, String, null: true
end