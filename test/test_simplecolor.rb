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

	it "Can be used directly" do
		SimpleColor.color("red",:red).must_equal "\e[31mred\e[0m"
	end

	it "Can specify several colors" do
		SimpleColor.color("red",:red,:bold).must_equal "\e[31;1mred\e[0m"
	end

	it "Can take a block" do
		SimpleColor.color(:red) { "red" }.must_equal "\e[31mred\e[0m"
	end

	it "Can provide only color values" do
		SimpleColor.color(:red).must_equal "\e[31m"
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

	describe "It can be mixed in strings" do
		before do
			SimpleColor.mix_in_string
		end

		it "Works on strings" do
			"red".color(:red).must_equal "\e[31mred\e[0m"
		end

		it "Uncolor works on strings" do
			"red".color(:red).uncolor.must_equal "red"
		end

		it "color does not affects the string" do
			s="red"
			s.color(:red)
			s.must_equal "red"
		end

		it "color! does affects the string" do
			s="red"
			s.color!(:red)
			s.must_equal "\e[31mred\e[0m"
		end

		it "uncolor does not affects the string" do
			s="\e[31mred\e[0m"
"red"
			s.uncolor
			s.must_equal "\e[31mred\e[0m"
		end

		it "uncolor! does not affects the string" do
			s="\e[31mred\e[0m"
"red"
			s.uncolor!
			s.must_equal "red"
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

		it "When disabled uncolor should still work" do
			word="\e[31mred\e[0m"
			SimpleColor.uncolor(word).must_equal "red"
		end
	end

	describe "It can copy colors" do
		it "Copy one color" do
			SimpleColor.copy_colors(SimpleColor.color("red",:red),"blue").must_equal "\e[31mblue\e[0m"
		end

		it "Copy several colors" do
			SimpleColor.copy_colors(SimpleColor.color("red",:red,:bold),"blue").must_equal "\e[31;1mblue\e[0m"
		end
	end

end
