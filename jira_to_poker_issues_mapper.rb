module Mappers
  class JiraToPokerMapperClass
    attr_reader :jira_host

    def initialize(config)
      @jira_host = config.host
    end

    def call(jira_issues)
      jira_issues.map do |issue|
        {
          :name => issue[:fields][:summary],
          :type => issue[:fields][:issuetype][:name],
          :referenceId => issue[:key],
          :link => jira_host << "/browse/#{issue[:key]}",
          :description => issue[:fields][:description],
          :acceptanceCriteria => ''
        }
      end
    end
  end
end
