module Api::V1
  class UsersController < ApplicationController
    def request_one_time_password
      # phone = params[:user][:phone]
      # found_user.update(code: '1234', code_valid: true)
      message = does_user_have_account
      status = 200
      @client = Twilio::REST::Client.new twilio[:account_sid], twilio[:auth_token]

      begin
        @client.api.account.messages.create(
          from: twilio_phone,
          to: params[:user][:phone],
          body: "Your Cure8 one time password is #{one_time_password}.",
        )
      rescue Twilio::REST::TwilioError => error
        puts error.message
      end
      if error
        message = error.message
        status = error.status_code
      end
      render json: { message: message, status: status }
    end

    # TODO do I need this?
    def authenticate
      code = params[:user][:code]
      found_user.code_valid && found_user.code == code
    end

    def add_push_token(push_token)
      if push_token && !Token.where(token: push_token).exists?
        user.tokens.create(token: push_token, token_type: 'push')
      end
      render json: { status: 200 }
    end

    def get_contacts
      render json: { contacts: user.contacts.compact, groups: user.contact_groups, status: 200 }
    end

    def delete_contact
      contact_group = Group.find(params[:contact][:id])
      remove_user_from_groups(params[:contact][:id])
      contact_group.destroy
      render json: { contacts: user.contacts.compact, groups: user.contact_groups, status: 200 }
    end

    def get_user_info
      notifications = {
        push: user.notifications,
        curation: user.notifications_new_link,
        rating: user.notifications_new_rating,
        show_tour: user.show_tour
      }
      render json: {
        stats: user.stats,
        name: user.name,
        phone: user.phone,
        notifications: notifications,
        status: 200
      }
    end

    def update
      field = params[:user][:field]
      symbol = "#{field}".to_sym
      value = params[:user][:value]
      if field == 'push'
        add_push_token(value)
      else
        user.update_attribute(symbol, value)
        get_user_info
      end
    end

    def activity
      activity = ratings.concat(saved_curations)
      sorted = activity.sort_by! { |a| a[:date] }.reverse
      render json: { data: sorted, status: 200 }
    end

    private

    def found_user
      @found_user ||= User.find_or_create_by(phone: params[:user][:phone])
    end

    def user
      @user ||= db_token.user
    end

    def db_token
      @db_token ||= Token.find_by(token: params[:user][:token])
    end

    def one_time_password
      code = rand(100000..999999)
      found_user.update(code: code, code_valid: true)
      code
    end

    def does_user_have_account
      return 'Login' if found_user.first_name
      return 'Create Account'
    end

    def remove_user_from_groups(contact_id)
      user.groups.each do |group|
        if group.members and group.members.include? contact_id
          group.members.delete contact_id
          group.save
        end
      end
    end

    def ratings
      ratings = Curation.where(curator_id: user.id).
        order('updated_at desc').
        where.not(rating: nil).
        limit(10)
      ratings.map do |rating|
        link = Link.find(rating.link_id)
        friend = User.find(rating.user_id)
        {
          id: rating.id,
          date: rating.updated_at,
          rating: rating.rating,
          title: link.title,
          url: link.url,
          type: 'rating',
          friend: friend.name
        }
      end
    end

    def saved_curations
      links = Link.where(link_owner: user.id).order('created_at desc').limit(10)
      links.map do |link|
        friends = link.curations.map do |curation|
          user = User.find(curation.user_id)
          user.name if user.name
        end
        {
          id: link.id,
          date: link.updated_at,
          title: link.title,
          url: link.url,
          type: 'curation',
          friends: friends
        }
      end
    end

    def twilio
      {
        account_sid: Rails.application.secrets.twilio_account_sid,
        auth_token: Rails.application.secrets.twilio_auth_token
      }
    end

    def twilio_phone
      if params[:user][:phone].split('')[1] === '1'
        '+17608198213'
      else
        '+61429806720'
      end
    end

  end
end
