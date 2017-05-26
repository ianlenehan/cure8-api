module Api::V1
  class GroupsController < ApplicationController

    def create_contact
      user = User.find(params[:user][:id])
      phone = params[:contact][:phone]
      contact = User.find_or_create_by(phone: phone)
      name = params[:contact][:name]

      group = user.groups.create
      group.update(
        group_owner: user.id,
        name: name,
        members: [contact.id]
      )

      render json: { contacts: user.contacts, groups: user.contact_groups, status: 200 }
    end
  end
end
