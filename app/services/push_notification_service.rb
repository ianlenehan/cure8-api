class PushNotificationService
  def initialize(new_http_client=nil)
    @http_client = new_http_client || HTTParty
  end

  def publish(messages)
    response = @http_client.post('https://exp.host/--/api/v2/push/send',
      body: messages.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Accept-Encoding' => 'gzip, deflate'
      }
    )

    case response.code
      when 400
        raise PushNotificationService::Errors::InvalidPushTokenError
    end
  end

  module Errors
    class InvalidPushTokenError < StandardError
    end
  end
end
