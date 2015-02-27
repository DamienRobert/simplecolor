require 'helper'
require 'simplecolor'

class TestSimpleColor < MiniTest::Test

	def test_version
		version = SimpleColor.const_get('VERSION')

		assert(!version.empty?, 'should have a VERSION constant')
	end

end

describe SimpleColor do
	before do
		SimpleColor.enabled=true
	end

	it "Can be mixed in strings" do
		SimpleColor.mix_in_string
		"red".color(:red).must_equal "\e[31mred\e[0m"
	end

	it "Can be used directly" do
		SimpleColor.color("red",:red).must_equal "\e[31mred\e[0m"
	end

	it "can uncolor" do
		SimpleColor.uncolor(SimpleColor.color("red",:red)).must_equal "red"
	end

	describe "Shell mode" do
		before do
			SimpleColor.enabled=:shell
		end

		it "Wraps color into shell escapes" do
			SimpleColor.color("red",:red).must_equal "%{\e[31m%}red%{\e[0m%}"
		end
	end

	describe "It can be disabled" do
		before do
			SimpleColor.enabled=false
		end

		it "When disabled color should be a noop" do
			word="red"
			SimpleColor.color(word,:red).must_equal word
		end

		it "When disabled uncolor should be a noop" do
			word="\e[31mred\e[0m"
			SimpleColor.uncolor(word).must_equal word
		end
	end

end
