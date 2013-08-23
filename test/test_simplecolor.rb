require 'helper'
require 'simplecolor'

class TestSimplecolor < MiniTest::Test

  def test_version
    version = Simplecolor.const_get('VERSION')

    assert(!version.empty?, 'should have a VERSION constant')
  end

end
