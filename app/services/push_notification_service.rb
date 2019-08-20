class PushNotificationService
  def initialize(new_http_client=nil)
    @http_client = new_http_client || HTTParty
  end

  def publish(user_token, details)
    body_content = {
      'app_id' => onesignal[:app_id],
      'include_player_ids' => [user_token],
      'contents' => { 'en': details[:title] },
      'headings' => { 'en': get_heading(details) },
      'ios_badgeType' => 'Increase',
      'ios_badgeCount' => 1
    }

    response = @http_client.post(post_url,
      body: body_content.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Basic #{onesignal[:rest_api_key]}",
      }
    )

    case response.code
      when 400
        raise PushNotificationService::Errors::InvalidPushTokenError
    end
  end

  def get_heading(details)
    if (details[:type] == 'rating')
      "#{details[:reaction]} from #{details[:from]}"
    elsif (details[:type] == 'curation')
      "New curation from #{details[:from]}"
    elsif (details[:type] == 'chat')
      "New message from #{details[:from]}"
    else
      details[:type]
    end
  end

  def post_url
    'https://onesignal.com/api/v1/notifications'
  end

  def onesignal
    {
      app_id: Rails.application.secrets.one_signal_app_id,
      rest_api_key: Rails.application.secrets.one_signal_rest_api_key
    }
  end

  module Errors
    class InvalidPushTokenError < StandardError
    end
  end
end
