module Cache
  class LocalCache
    require 'fileutils'

    attr_reader :lifetime_sec

    def initialize(lifetime_sec, cache_path)
      @lifetime_sec = lifetime_sec
      @cache_path = cache_path || 'tmp/mhh-cache'
    end

    def put_battle_id(battle_id)
      put(battle_id)
    end

    def get_battle_id
      get.first
    end

    def purge
      FileUtils.rm_f(cache_path)
    end

    private
    def put(content)
      unless File.exist?(cache_path)
        dir = File.dirname(cache_path)
        unless File.directory?(dir)
          FileUtils.mkdir_p(dir)
        end
      end

      f = File.new(cache_path, 'w+')
      f.puts(content)
      f.close
    end

    def get
      if File.exist?(cache_path)
        if expired?(cache_path)
          raise Errors::CacheExpired
        else
          File.readlines(cache_path, chomp: true)
        end
      else
        raise Errors::CacheNotFound
      end
    end

    def expired?(file_path)
      Time.now.to_i >= (last_updated(file_path) + lifetime_sec)
    end

    def last_updated(file_path)
      File.mtime(file_path).to_i
    end

    def cache_path
      @cache_path
    end
  end

  module Errors
    class CacheExpired < StandardError
      def message
        'Cache expired'
      end
    end
    class CacheNotFound < StandardError
      def message
        'Cache file not found'
      end
    end
  end
end
