module Mutations
  class LeaveConversation < Mutations::BaseMutation

    description "Leaves a conversation"
    argument :conversation_id, String, required: true

    field :conversations, [Types::ConversationType], null: false
    field :errors, [String], null: true

    def resolve(conversation_id:)
      if (conversation = Conversation.find(conversation_id))
        conversation.users.delete(current_user)

        if !Conversation.find(conversation_id).users.count
          conversation.destroy
        end
        conversations = current_user.conversations.uniq
        { conversations: conversations, errors: [] }
      else
        { errors: ["That covnersation does not exist"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end
  end
end

