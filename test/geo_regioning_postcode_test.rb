require File.dirname(__FILE__) + '/test_helper'

class GeoRegioningPostcodeTest < Test::Unit::TestCase
  load_schema

  def test_postcode
    country = GeoRegioning::Country.create(:iso_3166 => 'AU')
    level = GeoRegioning::Level.create(:long_name => 'Victoria', :country => country, :parent => country)
    postcode = GeoRegioning::Postcode.create(:code => 3806, :country => country)
    level.postcodes << postcode

    assert_not_nil level.postcodes
  end
end