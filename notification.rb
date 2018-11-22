require "faraday"
require "json"
module PushOver
  class Message
    def initialize(user_token, app_token)
      @conn = Faraday.new(url: 'https://api.pushover.net/1/messages.json')
      @user_token = user_token
      @app_token = app_token
    end

    def send(title, message, device=nil)
      response = @conn.post do |req|
        req.params['token'] = @app_token
        req.params['user'] = @user_token
        req.params['device'] = device if device
        req.params['title'] = title
        req.params['message'] = message
      end
      return JSON.load(response.body)
    end
  end
  class Glances
    def initialize(user_token, app_token)
      @conn = Faraday.new(url: 'https://api.pushover.net/1/glances.json')
      @user_token = user_token
      @app_token = app_token
    end

    def send(title, text, subtext, device=nil)
      response = @conn.post do |req|
        req.params['token'] = @app_token
        req.params['user'] = @user_token
        req.params['device'] = device if device
        req.params['title'] = title
        req.params['text'] = text
        req.params['subtext'] = subtext
      end
      return JSON.load(response.body)
    end
  end
end

# PUSHOVER_USER_KEY=ENV["PUSHOVER_USER_KEY"]
# PUSHOVER_APPLICATION_KEY=ENV["PUSHOVER_APPLICATION_KEY"]
#
# messanger = PushOver:Message.new(PUSHOVER_USER_KEY, PUSHOVER_APPLICATION_KEY)
#
# puts messanger.send("Test Messager", "test message")
