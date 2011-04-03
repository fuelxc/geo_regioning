require File.dirname(__FILE__) + '/test_helper'

class GeoRegioningPostcodeTest < Test::Unit::TestCase
  load_schema

  def test_country
    assert_kind_of GeoRegioning::Postcode, GeoRegioning::Postcode.new
  end
end