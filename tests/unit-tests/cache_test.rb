require 'minitest/autorun'
require 'fileutils'
require 'delorean'

require_relative '../../cache'

class LocalCacheTest < Minitest::Test
  attr_reader :cache, :test_cache_path

  def setup
    @test_cache_path = 'tests/unit-tests/tmp/test-cache'
    @cache = Cache::LocalCache.new(3600, test_cache_path)
  end

  def teardown
    FileUtils.rm_f(test_cache_path)

    dir = File.dirname(test_cache_path)
    FileUtils.rmdir(dir) if File.exist?(dir)
  end

  def test_cache_battle_id_succesfully
    battle_id = 'test_battle_id'

    cache.put_battle_id(battle_id)

    assert_path_exists(test_cache_path)

    saved_battle_id = File.readlines(test_cache_path, chomp: true).first
    assert_equal(battle_id, saved_battle_id)
  end

  def test_get_battle_id_succesfully
    battle_id = 'test_battle_id'
    populate_test_cache(battle_id)

    fetched_battle_id = cache.get_battle_id

    assert_equal(battle_id, fetched_battle_id)
  end

  def test_cache_expires
    assert_raises(Cache::Errors::CacheExpired) do
      populate_test_cache('expired_battle_id')

      Delorean.jump 3600

      cache.get_battle_id
    end
  end

  def test_cache_not_found
    assert_raises(Cache::Errors::CacheNotFound) do
      cache.get_battle_id
    end
  end

  def test_purge_cache_sucessfully
    populate_test_cache('purged_battle_id')

    cache.purge

    refute_path_exists(test_cache_path)
  end

  def test_purge_unexisting_cache
    cache.purge

    refute_path_exists(test_cache_path)
  end

  private

  def populate_test_cache(content)
    FileUtils.mkdir_p(File.dirname(test_cache_path))
    f = File.new(test_cache_path, 'w+')
    f.puts(content)
    f.close
  end
end
