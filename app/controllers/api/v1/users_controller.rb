module Api::V1
  class UsersController < ApplicationController

    def index
      render json: User.all
    end

    def show
      respond_with User.find(params[:id])
    end

    def request_one_time_password
      phone = params[:phone].gsub(/[^\d]/, '')
      user = User.find_or_create_by(phone: phone)
      user.update(code: '1234', code_valid: true)
      buttonText = does_user_have_account(user)
      # @client = Twilio::REST::Client.new twilio[:account_sid], twilio[:auth_token]
      # message = @client.account.messages.create(
      #   :body => "Your cure8 one time password is #{one_time_password}.",
      #   :to => phone,
      #   :from => "+61439765683"
      #   )
      render json: { buttonText: buttonText, status: 200 }
    end

    def authenticate
      code = params[:user][:code]
      user.code_valid && user.code == code
    end

    def get_contacts
      puts 'get contacts'
      user = User.find(params[:user][:id])
      puts 'user'
      puts user
      render json: { contacts: user.contacts.compact, groups: user.contact_groups, status: 200 }
    end

    private

    def user
      @user || (find_user_by_phone || create_user_by_phone)
    end

    def find_user_by_phone
      User.where(phone: params[:user][:phone])
    end

    def create_user_by_phone
      User.create(phone: params[:user][:phone])
    end

    def one_time_password
      code = rand(100000..999999)
      user.update(code: code, code_valid: true)
      code
    end

    def does_user_have_account(user)
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
