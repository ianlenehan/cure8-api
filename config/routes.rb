Rails.application.routes.draw do

  namespace :api, defaults:{ format: :json } do
    namespace :v1 do
      # resources :users

      post 'users/request' => 'users#request_one_time_password'
    end
  end

end
