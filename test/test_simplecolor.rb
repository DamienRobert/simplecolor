require 'helper'
require 'simplecolor'

class TestSimpleColor < MiniTest::Test

  def test_version
    version = SimpleColor.const_get('VERSION')

    assert(!version.empty?, 'should have a VERSION constant')
  end

end

describe SimpleColor do
  it "Can be mixed in strings" do
    SimpleColor.mix_in_string
    "red".color(:red).must_equal "\e[31mred\e[0m"
  end

  it "Can be used directly" do
    SimpleColor.color("red",:red).must_equal "\e[31mred\e[0m"
  end
end
