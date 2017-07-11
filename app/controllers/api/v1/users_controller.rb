module Api::V1
  class UsersController < ApplicationController
    def request_one_time_password
      # phone = params[:user][:phone]
      # found_user.update(code: '1234', code_valid: true)
      buttonText = does_user_have_account
      @client = Twilio::REST::Client.new twilio[:account_sid], twilio[:auth_token]
      message = @client.account.messages.create(
        :body => "Your cure8 one time password is #{one_time_password}.",
        :to => phone,
        # :from => "+15005550006"
        :from => "+61429806720"
        )
      render json: { buttonText: buttonText, status: 200 }
    end

    def authenticate
      code = params[:user][:code]
      found_user.code_valid && found_user.code == code
    end

    def add_push_token
      token = params[:token][:token]
      user.update(push_token: token)
      render json: { status: 200 }
    end

    def update
      user.update(update_params)
    end

    def get_contacts
      render json: { contacts: user.contacts.compact, groups: user.contact_groups, status: 200 }
    end

    def delete_contact
      contact_group = Group.find(params[:contact][:id])
      remove_user_from_groups(params[:contact][:id])
      contact_group.destroy
      render json: { contacts: user.contacts.compact, groups: user.contact_groups, status: 200 }
    end

    def get_user_info
      notifications = {
        push: user.notifications,
        curation: user.notifications_new_link,
        rating: user.notifications_new_rating
      }
      render json: {
        stats: user.stats,
        name: user.name,
        phone: user.phone,
        notifications: notifications,
        status: 200
      }
    end

    def update
      field = params[:user][:field]
      symbol = "#{field}".to_sym
      value = params[:user][:value]

      user.update_attribute(symbol, value)
      get_user_info
    end

    private

    def found_user
      @found_user || User.find_or_create_by(phone: params[:user][:phone])
    end

    def user
      @user || User.find(params[:user][:id])
    end

    def one_time_password
      code = rand(100000..999999)
      user.update(code: code, code_valid: true)
      code
    end

    def does_user_have_account
      return 'Login' if found_user.first_name
      return 'Create Account'
    end

    def remove_user_from_groups(contact_id)
      user_by_id.groups.each do |group|
        if group.members and group.members.include? contact_id
          group.members.delete contact_id
          group.save
        end
      end
    end

    def twilio
      {
        account_sid: Rails.application.secrets.twilio_account_sid,
        auth_token: Rails.application.secrets.twilio_auth_token
      }
    end

  end
end
