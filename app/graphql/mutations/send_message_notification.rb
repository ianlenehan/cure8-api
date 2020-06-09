module Mutations
  class SendMessageNotification < Mutations::BaseMutation

    description "Sends a new message notification"
    argument :conversation_id, String, required: true
    argument :message, String, required: true

    field :conversation, Types::ConversationType, null: false
    field :errors, [String], null: true

    def resolve(conversation_id:, message:)
      conversation = Conversation.find(conversation_id)
      if (create_notification(conversation, message))
        { conversation: conversation, errors: [] }
      else
        { errors: ["There was a problem sending the notification!"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end

    def create_notification(conversation, message)
      # users = conversation.users.filter { |user| user.id != current_user.id }
      users = conversation.users

      details = {
        from: current_user.name,
        title: conversation.title,
        type: 'chat'
      }

      users.map do |user|
        send_notification(user, details)
      end
    end

    def send_notification(user, details)
      user.push_tokens.each do |push_token|
        if push_token.notify && push_token.notify_new_link
          push_notification.publish(push_token.token, details)
        end
      end
    end

    def push_notification
      @push_notification ||= PushNotificationService.new
    end

  end
end