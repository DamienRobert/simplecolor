require 'helper'
require 'simplecolor'

class TestSimpleColor < MiniTest::Test

  def test_version
    version = SimpleColor.const_get('VERSION')

    assert(!version.empty?, 'should have a VERSION constant')
  end

end
