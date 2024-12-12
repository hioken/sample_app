require "test_helper"

class ChannelTest < ActiveSupport::TestCase
  test 'should be valid' do
    puts '&' * 100
    p channels(:one)
  end
end
