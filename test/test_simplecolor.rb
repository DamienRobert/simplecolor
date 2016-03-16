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

	it "Accepts ANSI sequences" do
		SimpleColor.color("red","\e[31;1m").must_equal "\e[31;1mred\e[0m"
	end

	it "Can mix ANSI sequences and attributes" do
		SimpleColor.color("red",:inverse,"\e[31m",:bold).must_equal "\e[31;1mred\e[0m"
	end

	it "Can take a block" do
		SimpleColor.color(:red) { "red" }.must_equal "\e[31mred\e[0m"
	end

	it "Can provide only color values" do
		SimpleColor.color(:red).must_equal "\e[31m"
	end

	it "Does not change the string when there is no color attributes" do
		SimpleColor.color("foo").must_equal "foo"
	end

	it "can uncolor" do
		SimpleColor.uncolor(SimpleColor.color("red",:red)).must_equal "red"
	end

	it "Can detect colored strings" do
		SimpleColor.color?("red").must_equal false
		SimpleColor.color?(SimpleColor.color("red",:red)).must_equal true
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

	describe "It has colors helpers utilities" do
		it "It can copy one color" do
			SimpleColor.copy_colors(SimpleColor.color("red",:red),"blue").must_equal "\e[31mblue\e[0m"
		end

		it "Copy several colors" do
			SimpleColor.copy_colors(SimpleColor.color("red",:red,:bold),"blue").must_equal "\e[31;1mblue\e[0m"
		end

		it "Can recover colors" do
			b,e,l=SimpleColor.current_colors(SimpleColor.color("red",:red,:bold))
			b.must_equal "\e[31;1m"
			e.must_equal "\e[0m"
			l.must_equal "red"
		end

		it "Can get colors attributes" do
			b,e,l=SimpleColor.current_colors(SimpleColor.color("red",:red,:bold))
			SimpleColor.attributes_from_colors("\e[m"+b+e).must_equal([:clear,:red,:bold,:clear])
		end

		it "Can split a string into color entities" do
			SimpleColor.color_entities(SimpleColor.color("red",:red,:bold)+SimpleColor.color("blue",:blue)).must_equal(["", "\e[31;1m", "r", "", "e", "", "d", "\e[0m\e[34m", "b", "", "l", "", "u", "", "e", "\e[0m"])
		end
	end

end
