Rails.application.routes.draw do

  namespace :api, defaults:{ format: :json } do
    namespace :v1 do
      # resources :users
      post 'login' => 'sessions#create'
      post 'users/request' => 'users#request_one_time_password'
      post 'user/contacts' => 'users#get_contacts'
      # get 'verify' => 'sessions#verify_access_token'

      post 'links/create' => 'links#create_link'
      post 'links/fetch' => 'links#get_links'
      post 'links/archive' => 'links#archive'
      post 'contacts/create' => 'groups#create_contact'
    end
  end

end
