class Cure8ApiSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
end
