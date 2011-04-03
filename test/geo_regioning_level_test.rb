require File.dirname(__FILE__) + '/test_helper'

class GeoRegioningLevelTest < Test::Unit::TestCase
  load_schema

  def test_level
    assert_kind_of GeoRegioning::Level, GeoRegioning::Level.new
  end

  def test_level_one

  end
end