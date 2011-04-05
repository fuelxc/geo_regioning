require File.dirname(__FILE__) + '/test_helper'

class GeoRegioningLevelTest < Test::Unit::TestCase
  load_schema

  def test_first_level_addressing
    country = GeoRegioning::Country.create(:name => 'Australia', :iso_3166 => 'AU')
    level1 = GeoRegioning::Level.create(:depth => 1, :country => country, :long_name => 'Victoria', :short_code => 'VIC', :parent => country)

    assert_equal country, level1.parent
    assert_equal "Victoria, AU", level1.address
  end

  def test_hidden_addressing
    country = GeoRegioning::Country.create(:name => 'Australia', :iso_3166 => 'AU')
    level1 = GeoRegioning::Level.create(:long_name => 'Victoria', :short_code => 'VIC', :parent => country)
    level2 = GeoRegioning::Level.create(:long_name => 'Casey', :parent => level1)
    level3 = GeoRegioning::Level.create(:long_name => 'Berwick', :parent => level2)

    assert_equal level2, level3.parent
    assert_equal 3, level3.depth
    assert_equal country, level3.country
    assert_equal "Berwick, Victoria, AU", level3.address
  end

  def test_auto_coding
    country = GeoRegioning::Country.create(:name => 'Australia', :iso_3166 => 'AU')
    level1 = GeoRegioning::Level.create(:depth => 1, :country => country, :long_name => 'Victoria', :short_code => 'VIC', :parent => country)
    assert_not_nil level1.lat_long
  end

end