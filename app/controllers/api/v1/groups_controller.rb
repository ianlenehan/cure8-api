module Api::V1
  class GroupsController < ApplicationController

    def create_contact
      phone = params[:contact][:phone]
      contact = find_or_create_contact(phone)
      name = params[:contact][:name]
      if !contact_already_exists(phone)
        group = user.groups.create
        group.update(
        group_owner: user.id,
        name: name,
        user_id: contact.id
        )
      end
      render json: { contacts: user.contacts, groups: user.contact_groups, status: 200 }
    end

    def create_group
      name = params[:group][:name]
      members = params[:group][:members]
      contacts = members.map do |member|
        contact = Group.find_by(id: member, group_owner: user.id)
      end

      group = user.groups.create
      group.update(group_owner: user.id, name: name, members: [])
      contacts.each { |contact| group.members << contact.id }
      group.save

      render json: { contacts: user.contacts, groups: user.contact_groups, status: 200 }
    end

    def edit_group
      group = Group.find(params[:group][:id])
      members = params[:group][:members]
      name = params[:group][:name]
      contacts = members.map do |member|
        contact = Group.find_by(id: member, group_owner: user.id)
      end

      group.update(name: name, members: [])
      contacts.each { |contact| group.members << contact.id }
      group.save

      render json: { contacts: user.contacts, groups: user.contact_groups, status: 200 }
    end

    private

    def user
      @user ||= db_token.user
    end

    def db_token
      @db_token ||= Token.find_by(token: params[:user][:token])
    end

    def find_or_create_contact(phone)
      User.find_or_create_by(phone: phone)
    end

    def contact_already_exists(phone)
      user.contacts.any? { |contact| contact[:phone] == phone }
    end
  end
end
