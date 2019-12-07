module Mutations
  class DeleteCuration < Mutations::BaseMutation

    description "Deletes a curation"
    argument :id, String, required: true

    field :curations, [Types::CurationType], null: false
    field :errors, [String], null: true

    def resolve(id:)
      if (Curation.find(id).destroy)
        { curations: current_user.curations, errors: [] }
      else
        { errors: ["There was a problem deleting the curation"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end
    
  end
end