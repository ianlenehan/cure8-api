module Api::V1
  class AuthenticationController < ApplicationController
    skip_before_action :authenticate_request
  
    def authenticate
      command = AuthenticateUser.call(params[:phone], params[:code])
  
      if command.success?
        render json: { auth_token: command.result, current_user: found_user }
      else
        render json: { error: command.errors }, status: :unauthorized
      end
    end

    def request_one_time_password
      status = 200
      registration_required = !found_user.first_name

      if Rails.env == 'development'
        phone = params[:phone]
        found_user.update(code: '1234', code_valid: true)
      else
        @client = Twilio::REST::Client.new twilio[:account_sid], twilio[:auth_token]

        begin
          @client.api.account.messages.create(
            from: twilio_phone,
            to: params[:phone],
            body: "Your Cure8 one time password is #{one_time_password}."
          )
        rescue Twilio::REST::TwilioError => error
          puts error.message
        end
        if error
          message = error.message
          status = error.status_code
        end
      end
      render json: { registration_required: registration_required, status: status }
    end

    private

    def found_user
      @found_user ||= User.find_or_create_by(phone: params[:phone])
    end

    def twilio
      {
        account_sid: Rails.application.credentials.twilio[:account_sid],
        auth_token: Rails.application.credentials.twilio[:auth_token]
      }
    end

    def twilio_phone
      if params[:phone].split('')[1] == '1'
        '+17608198213'
      else
        '+61429806720'
      end
    end
  end
end