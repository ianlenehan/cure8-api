class Types::ActivityType < Types::BaseObject
  field :id, String, null: false
  field :url, String, null: false
  field :title, String, null: false
  field :created_at, String, null: false
  field :ratings, [Types::RatingType], null: true
end