module Mutations
  class DeleteGroup < Mutations::BaseMutation

    description "Deletes a contact group"
    argument :id, String, required: true

    field :groups, [Types::GroupType], null: false
    field :errors, [String], null: true

    def resolve(id:)
      if (Group.find(id).destroy)
        groups = current_user.groups
        { groups: groups, errors: [] }
      else
        { errors: ["There was a problem deleting the group"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end

  end
end