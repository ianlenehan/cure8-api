module Mutations
  class CreateGroup < Mutations::BaseMutation

    description "Creates a new contact group"
    argument :name, String, required: true
    argument :member_ids, [String], required: true

    field :group, Types::GroupType, null: false
    field :errors, [String], null: true

    def resolve(name:, member_ids:)
      if (group = create_group(name, member_ids))
      
        { group: group, errors: [] }
      else
        { errors: ["There was a problem creating the group"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end

    def create_group(name, member_ids)
      current_user.groups.create(name: name, member_ids: member_ids)
    end

    def contact_already_exists(phone)
      user.contacts.any? { |contact| contact[:phone] == phone }
    end

  end
end