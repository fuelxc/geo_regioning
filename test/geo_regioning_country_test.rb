require File.dirname(__FILE__) + '/test_helper'

class GeoRegioningCountryTest < Test::Unit::TestCase
  load_schema

  def test_country
    assert_kind_of GeoRegioning::Country, GeoRegioning::Country.new
    country = GeoRegioning::Country.create(:iso_3166 => 'AU', :name => 'Australia' )
    assert_not_nil country.geo_latitude
  end
end