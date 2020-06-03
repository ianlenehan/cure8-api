module Mutations
  class CreateConversation < Mutations::BaseMutation

    description "Creates a new conversation"
    argument :link_id, String, required: true
    argument :user_ids, [String], required: true

    field :conversation, Types::ConversationType, null: false
    field :errors, [String], null: true

    def resolve(link_id:, user_ids:)
      conversation = create_conversation(link_id, user_ids)
      if (conversation)
        { conversation: conversation, errors: [] }
      else
        { errors: ["There was a problem creating the user"] }
      end
    end

    private

    def current_user
      context[:current_user]
    end

    def create_conversation(link_id, user_ids)
      link = Link.find(link_id)
      existing_conversation = find_conversation(link_id, user_ids)
      if existing_conversation
        conversation = existing_conversation
      else
        conversation = Conversation.create({
          title: link.title,
          link_id: link.id
        })

        set_conversation_users(conversation, user_ids)
      end
      conversation
    end

    def set_conversation_users(conversation, user_ids)
      chat_members = user_ids.map { |id| conversation.users << User.find(id) }
      conversation.users << chat_members
      conversation.users << current_user
      conversation.save
    end
    
    def find_conversation(link_id, user_ids)
      chats = Conversation.where(link_id: link_id)
      link_chat_exists = chats.length > 0
      user_chats = chats.select { |chat| chat.users.exists?(current_user.id) }
      existing_chat = nil
    
      if user_chats.length && link_chat_exists
        if user_ids.length > 1
          existing_chat = user_chats.select { |chat| chat.users.length > 2 }.first
        else
          existing_chat = user_chats.select { |chat| chat.users.length == 2 }.first
        end
      end
      existing_chat
    end

  end
end

