class ApplicationController < ActionController::API
  def get_user_from_token(token)
    decoded_token = JWT.decode token, nil, false
    user_id = decoded_token.first["id"]
    User.find(user_id)
  end
end
