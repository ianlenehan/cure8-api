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
      User.find_or_create_by(phone: phone)
      puts "after user"
      @client = Twilio::REST::Client.new twilio[:account_sid], twilio[:auth_token]
      puts "after client"
      message = @client.account.messages.create(
        :body => "Your cure8 one time password is #{one_time_password}.",
        :to => phone,
        :from => "+61439765683"
        )
      puts "Message is #{message}"
      render json: { text: "verified", status: 200 }
    end

    def authenticate
      code = params[:user][:code]
      user.code_valid && user.code == code
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

    def twilio
      {
        account_sid: Rails.application.secrets.twilio_account_sid,
        auth_token: Rails.application.secrets.twilio_auth_token
      }
    end

  end
end
