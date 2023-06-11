require 'rest-client'
require 'date'

module Gateways
  class PokerGateway
    attr_reader :username, :password, :host

    def initialize(config)
      @username = config.username
      @password = config.password
      @host = config.host
    end

    def create_battle_with_plans(plans)
      puts 'Creating poker battle...'

      auth_result = authenticate

      if auth_result[:success]
        user_id = auth_result[:user_id]
        session = auth_result[:session_id]

        result = RestClient.post(
          create_battle_url(user_id),
          battle_params(user_id, plans),
          {:cookies => {:sessionId => session}}
        )

        make_response(JSON.parse(result, {:symbolize_names => true}))
      else
        make_response(auth_result)
      end

    rescue RestClient::Exception => e
      make_response(JSON.parse(e.response, {:symbolize_names => true}))
    end

    private

    def authenticate
      result = RestClient.post(
        auth_url,
        {:email => username, :password => password}.to_json,
        {content_type: :json, accept: :json}
      )

      json_result = JSON.parse(result, {:symbolize_names => true})

      {:success    => json_result[:success],
       :error      => json_result[:error],
       :user_id    => json_result[:data][:user][:id],
       :session_id => result.cookies["sessionId"]}
    end

    def battle_params(user_id, plans)
      {:battleLeaders => [
          user_id],
       :name => current_day,
       :votingLocked => true,
       :activePlanId => '',
       :pointValuesAllowed => [
         '1',
         '2',
         '3',
         '5',
         '8',
         '13'],
       :pointAverageRounding => 'round',
       :autoFinishVoting => true,
       :plans => plans}.to_json
    end

    def current_day
      sysdate = DateTime.now

      sysdate.strftime "%d.%m.%Y"
    end

    def make_response(result)
      if result[:success]
        {:error => 0,
         :message => 'Success',
         :battle_link => build_battle_link(result[:data][:id])}
      else
        {:error => 500, :message => result[:error]}
      end
    end

    def auth_url
      "#{host}/api/auth"
    end

    def create_battle_url(user_id)
      "#{host}/api/users/#{user_id}/battles"
    end

    def build_battle_link(battle_id)
      "#{host}/battle/#{battle_id}"
    end
  end
end
