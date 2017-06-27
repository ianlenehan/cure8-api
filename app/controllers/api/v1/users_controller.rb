module Api::V1
  class UsersController < ApplicationController

    def index
      render json: User.all
    end

    def show
      respond_with User.find(params[:id])
    end

    def request_one_time_password
      phone = params[:phone]
      # user = User.find_or_create_by(phone: phone)
      # user.update(code: '1234', code_valid: true)
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
      user.code_valid && user.code == code
    end

    def get_contacts
      render json: { contacts: user_by_id.contacts.compact, groups: user_by_id.contact_groups, status: 200 }
    end

    def delete_contact
      contact_group = Group.find(params[:contact][:id])
      contact_group.destroy
      render json: { contacts: user_by_id.contacts.compact, groups: user_by_id.contact_groups, status: 200 }
    end

    def get_user_info
      render json: { stats: user_by_id.stats, name: user_by_id.name, status: 200 }
    end

    private

    def user
      @user || (find_user_by_phone || create_user_by_phone)
    end

    def user_by_id
      @user_by_id || User.find(params[:user][:id])
    end

    def find_user_by_phone
      User.find_by(phone: params[:user][:phone])
    end

    def create_user_by_phone
      User.create(phone: params[:user][:phone])
    end

    def one_time_password
      code = rand(100000..999999)
      user.update(code: code, code_valid: true)
      code
    end

    def does_user_have_account
      return 'Login' if user.first_name
      return 'Create Account'
    end

    def twilio
      {
        account_sid: Rails.application.secrets.twilio_account_sid,
        auth_token: Rails.application.secrets.twilio_auth_token
      }
    end

  end
end
