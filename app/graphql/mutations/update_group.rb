module Mutations
  class UpdateGroup < Mutations::BaseMutation

    description "Updates an existing contact group"
    argument :id, String, required: true
    argument :name, String, required: true
    argument :member_ids, [String], required: true

    field :group, Types::GroupType, null: false
    field :errors, [String], null: true

    def resolve(id:, name:, member_ids:)
      if (group = update_group(id, name, member_ids))
        { group: group, errors: [] }
      else
        { errors: ["There was a problem updating the group"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end

    def update_group(id, name, member_ids)
      group = Group.find(id)
      group.update(name: name, member_ids: member_ids)
      group
    end

  end
end