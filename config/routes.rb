Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  mount ActionCable.server => '/cable'
  get 'country' => 'generic#country_code'

  namespace :api, defaults: { format: :json } do

    namespace :v1 do
      post 'login' => 'sessions#create'
      post 'logout' => 'sessions#destroy'
      post 'users/request' => 'users#request_one_time_password'
      post 'user/contacts' => 'users#get_contacts'
      post 'user/contacts/delete' => 'users#delete_contact'
      post 'user/info' => 'users#get_user_info'
      post 'user/token' => 'users#add_push_token'
      post 'user/update' => 'users#update'
      post 'user/activity' => 'users#activity'
      post 'user/user_activity' => 'users#user_activity'
      post 'verify' => 'sessions#verify_access_token'

      post 'links/create' => 'links#create_link'
      post 'links/bookmarklet/safari' => 'links#create_link_from_safari'
      post 'links/bookmarklet' => 'links#create_link_from_web'
      post 'links/share_extension' => 'links#create_link_from_extension'
      post 'links/fetch' => 'links#get_links'
      post 'links/archive' => 'links#archive'
      post 'links/update_tags' => 'links#update_tags'
      post 'contacts/create' => 'groups#create_contact'
      post 'groups/create' => 'groups#create_group'
      post 'groups/update' => 'groups#edit_group'

      resources :conversations, only: [:index, :create]
      post 'user_conversations' => 'conversations#user_conversations'
      post 'conversations/reset' => 'conversations#reset_unread_count'
      post 'conversations/delete' => 'conversations#delete'
      resources :messages, only: [:create]
    end

    namespace :v2 do
      post 'links/create' => 'links#create_link'
      post 'links/bookmarklet' => 'links#create_link_from_web'
      post 'links/share_extension' => 'links#create_link_from_extension'
      post 'links/fetch' => 'links#get_links'
      post 'links/archive' => 'links#archive'
      post 'links/update_tags' => 'links#update_tags'
    end
  end
end
