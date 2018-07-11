module Api::V1
  class ConversationsController < ApplicationController
    def index
      conversations = Conversation.all
      render json: conversations
    end

    def create
      if existing_chat
        head :found
      else
        conversation = Conversation.new({
          title: conversation_link.title,
          link_id: conversation_link.id
          })
          if conversation.save
            set_conversation_users(conversation)
            serialized_data = ActiveModelSerializers::Adapter::Json.new(
              ConversationSerializer.new(conversation)
            ).serializable_hash
            ActionCable.server.broadcast 'conversations_channel', serialized_data
            head :ok
          end
      end
    end

    def user_conversations
      render json: app_user.conversations.uniq
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
      conversation.users << app_user
      conversation.save
    end

    def existing_chat
      chats = Conversation.where(link_id: params[:conversation][:link_id])
      link_chat_exists = chats.length > 0
      user_chat = chats.select { |chat| chat.users.include?(app_user) }
      if user_chat.length && link_chat_exists
        existing_chat = user_chat.first
      else
        existing_chat = nil
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
