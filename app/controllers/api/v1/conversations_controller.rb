module Api::V1
  class ConversationsController < ApplicationController
    def index
      conversations = Conversation.all
      render json: conversations
    end

    def create
      if existing_chat
        conversation = existing_chat
      else
        new_conversation = Conversation.new({
          title: conversation_link.title,
          link_id: conversation_link.id
          })
        if new_conversation.save
          set_conversation_users(new_conversation)
          serialized_data = ActiveModelSerializers::Adapter::Json.new(
            ConversationSerializer.new(new_conversation)
          ).serializable_hash
          ActionCable.server.broadcast 'conversations_channel', serialized_data
        end
        conversation = new_conversation
      end
      render json: conversation
    end

    def user_conversations
      render json: app_user.conversations.uniq, user: app_user
    end

    def reset_unread_count
      notification = UserNotification.find_or_create_by(
        user_id: app_user[:id],
        category: 'conversation',
        category_id: params[:conversation][:id],
      )
      notification.update(count: 0)
      user_conversations
    end

    private

    def user_params
      params.require(:user).permit(:token)
    end

    def conversation_link
      Link.find(params[:conversation][:link_id])
    end

    def set_conversation_users(conversation)
      member_ids = params[:conversation][:users_shared_with]
      chat_type = params[:conversation][:chat_type]
      if chat_type === 'group'
        member_ids.map { |id| conversation.users << User.find(id) }
      else
        conversation.users << conversation_link.owner
      end
      conversation.users << app_user if conversation.users.exclude?(app_user)
      conversation.save
    end

    def existing_chat
      chats = Conversation.where(link_id: params[:conversation][:link_id])
      chat_type = params[:conversation][:chat_type]
      link_chat_exists = chats.length > 0
      user_chats = chats.select { |chat| chats.first.users.exists?(app_user.id) }
      existing_chat = nil

      if user_chats.length && link_chat_exists
        if chat_type == 'single'
          existing_chat = user_chats.select { |chat| chat.users.length == 2 }.first
        elsif chat_type == 'group'
          existing_chat = user_chats.select { |chat| chat.users.length > 2 }.first
        end
      end
      existing_chat
    end

    def app_user
      db_token.user
    end

    def db_token
      Token.find_by(token: user_params[:token])
    end
  end
end
