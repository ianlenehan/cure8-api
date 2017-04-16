module Api::V1
  class SessionsController < ApplicationController

    # POST /v1/login
    def create
      user = User.find_by :email => params[:user][:phone]
      if user.present? && user.authenticate(user, params[:user][:code])
        session[:user_id] = user.id
        user.generate_access_token
        render json: => { user: user, status: 200 }
      else
        render json: => { text: 'Unable to verify user', status: 200 }
      end
    end

    def destroy
      session[:user_id] = nil
      user.destroy_access_token
      render json: => { text: "User logged out", status: 200 }
    end

    def verify_access_token
      user = User.find_by(access_token: params[:access_token])
      if user
        render text: "verified", status: 200
      else
        render text: "Token failed verification", status: 422
      end
    end

  end
end
