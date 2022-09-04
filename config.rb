require 'dry-struct'

module Types
  include Dry.Types()
end

class Config < Dry::Struct
  attribute :gateways do
    attribute :poker do
      attribute :username, Types::String
      attribute :password, Types::String
      attribute :host, Types::String
    end
    attribute :jira do
      attribute :username,             Types::String
      attribute :password,             Types::String
      attribute :host,                 Types::String
      attribute :issues_search_filter, Types::String
    end
  end
end
