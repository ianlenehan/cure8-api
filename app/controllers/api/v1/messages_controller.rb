module Api::V1
  class MessagesController < ApplicationController
    def create
      message = Message.new({
        text: message_params[:text],
        conversation_id: message_params[:conversation_id],
        user_id: app_user.id
      })
      conversation = Conversation.find(message_params[:conversation_id])
      conversation.touch
      if message.save
        send_notifications(conversation)
        serialized_data = ActiveModelSerializers::Adapter::Json.new(
          MessageSerializer.new(message)
        ).serializable_hash
        MessagesChannel.broadcast_to conversation, serialized_data
        head :ok
      end
    end

    private

    def send_notifications(conversation)
      details = {
        from: app_user.name,
        title: message_params[:text],
        type: 'chat'
      }
      conversation.users.each do |recipient|
        not_current_user = recipient.id != app_user.id
        update_notification_count(recipient, conversation)
        if recipient.notifications && not_current_user
          recipient.push_tokens.each do |push_token|
            push_notification.publish(push_token.token, details)
          end
        end
      end
    end

    def update_notification_count(recipient, conversation)
      puts "@@@@ rec id #{recipient.id} app user id #{app_user.id}"
      if recipient.id != app_user.id
        puts "@@@ ok adding it"
        notification = UserNotification.find_or_create_by(
          user_id: recipient[:id],
          category: 'conversation',
          category_id: conversation[:id],
        )
        notification.count += 1
        notification.save
      end
    end

    def message_params
      params.require(:message).permit(:text, :conversation_id)
    end

    def user_params
      params.require(:user).permit(:token)
    end

    def app_user
      db_token.user
    end

    def db_token
      Token.find_by(token: user_params[:token])
    end

    def push_notification
      @push_notification ||= PushNotificationService.new
    end
  end
end
