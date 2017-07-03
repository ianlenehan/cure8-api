Rails.application.routes.draw do

  namespace :api, defaults:{ format: :json } do
    namespace :v1 do
      # resources :users
      post 'login' => 'sessions#create'
      post 'users/request' => 'users#request_one_time_password'
      post 'user/contacts' => 'users#get_contacts'
      post 'user/contacts/delete' => 'users#delete_contact'
      post 'user/stats' => 'users#get_user_info'
      post 'user/token' => 'users#add_push_token'
      # get 'verify' => 'sessions#verify_access_token'

      post 'links/create' => 'links#create_link'
      post 'links/fetch' => 'links#get_links'
      post 'links/archive' => 'links#archive'
      post 'contacts/create' => 'groups#create_contact'
      post 'groups/create' => 'groups#create_group'
    end
  end

end
