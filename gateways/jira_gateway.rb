require 'rest-client'

module Gateways
  class Jira
    attr_reader :username, :password, :filter, :host

    def initialize(config)
      @username = config.username
      @password = config.password
      @host = config.host
      @filter = config.issues_search_filter
    end

    def get_issues
      puts 'Getting issues from jira...'

      result = search_resource.get :params => {:jql => filter}

      make_response(result)
    end

    private

    def search_url
      "#{host}/rest/api/2/search"
    end

    def search_resource
      RestClient::Resource.new search_url, username, password
    end

    def make_response(result)
      if result.code == 200
        json_result = JSON.parse(result, {:symbolize_names => true})

        if json_result[:total] > 0
          {:error => 0, :message => 'Success', :issues => json_result[:issues]}
        else
          {:error => 500, :message => 'Issues not found'}
        end
      else
        {:error => result.code, :message => result.slice(0, 100)}
      end
    end
  end
end
