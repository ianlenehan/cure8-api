module Api::V1
  class SessionsController < ApplicationController

    # POST /v1/login
    def create
      user = find_and_update_user
      if user.present?
        token = user.authenticate(params[:user][:code])
        if token
          session[:user_id] = user.id
          render json: { token: token, user: safe_user(user), status: 200 }
        else
          render json: { text: 'Unable to verify user', status: 422 }
        end
      else
        render json: { text: 'Unable to verify user', status: 422 }
      end
    end

    def destroy
      session[:user_id] = nil
      user.destroy_access_token
      render json: { text: "User logged out", status: 200 }
    end

    def verify_access_token
      user = User.find_by(access_token: params[:access_token])
      if user
        render text: "verified", status: 200
      else
        render text: "Token failed verification", status: 422
      end
    end

    private
    def safe_user(user)
      { id: user.id, name: user.name, phone: user.phone, shares: user.shares }
    end

    def find_and_update_user
      user = User.find_by :phone => params[:user][:phone]
      if !user.first_name
        first_name = params[:user][:first_name]
        last_name = params[:user][:last_name]
        user.update(first_name: first_name, last_name: last_name)
      end
      user
    end

  end
end
