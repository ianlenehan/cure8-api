module Mutations
  class DeleteCuration < Mutations::BaseMutation

    description "Deletes a curation"
    argument :id, String, required: true

    field :curations, [Types::CurationType], null: false
    field :errors, [String], null: true

    def resolve(id:)
      if (delete_curation(id))
        { curations: current_user.curations, errors: [] }
      else
        { errors: ["There was a problem deleting the curation"] }
      end
    end

    private

    def delete_curation(id)
      Curation.find(id).update(status: 'deleted')
    end

    def current_user
      context[:current_user]
    end
    
  end
end