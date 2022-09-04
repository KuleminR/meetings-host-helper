require_relative 'config'
require_relative 'gateways/jira_gateway'
require_relative 'gateways/poker_gateway'
require_relative 'jira_to_poker_issues_mapper'

require 'json'
require 'yaml'

SUCCESS = 0

def parse_config
  puts 'Parsing config...'
  data = YAML.load(File.read('config.yml'), symbolize_names: true)

  Config.new(data)
end

def respond(result)
  puts "Program ended with: #{result[:message]}"

  puts "Battle link: #{result[:battle_link]}" if result[:battle_link]
end

config = parse_config

jira_gateway = Gateways::Jira.new(config.gateways.jira)

JiraToPokerIssuesMapper = Mappers::JiraToPokerMapperClass.new(config.gateways.jira)

poker_gateway = Gateways::PokerGateway.new(config.gateways.poker)

result = jira_gateway.get_issues

if result[:error] == SUCCESS
  poker_prepared_plans = JiraToPokerIssuesMapper.(result[:issues])

  result = poker_gateway.create_battle_with_plans(poker_prepared_plans)
end

respond(result)

