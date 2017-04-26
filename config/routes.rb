Rails.application.routes.draw do

  namespace :api, defaults:{ format: :json } do
    namespace :v1 do
      # resources :users
      post 'login' => 'sessions#create'
      post 'users/request' => 'users#request_one_time_password'
      # get 'verify' => 'sessions#verify_access_token'

      post 'links/create' => 'links#create_link'
    end
  end

end
