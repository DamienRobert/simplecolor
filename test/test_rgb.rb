require 'helper'
require 'simplecolor'

describe SimpleColor::RGB do
	it "Should output truecolor code" do
		_(SimpleColor::RGB.new(10,20,30).ansi).must_equal "38;2;10;20;30"
	end
	it "Can degrade to 256 colors" do
		_(SimpleColor::RGB.new(10,20,30).convert(256).ansi).must_equal "38;5;234"
	end
	it "Can degrade to 16 colors" do
		_(SimpleColor::RGB.new(10,20,160).convert(16).ansi).must_equal "34"
	end
	it "Can degrade to 8 colors" do
		_(SimpleColor::RGB.new(10,20,30).convert(8).ansi).must_equal "30"
	end

	describe "List name" do
		it "Can specify color names" do
			_(SimpleColor::RGB.parse("lavender").to_hex).must_equal "#9F90D0"
		end
		it "Can specify the dict to use for color names" do
			_(SimpleColor::RGB.parse("x11:lavender").to_hex).must_equal "#E6E6FA"
		end
		it "Can use custom names" do
			_(SimpleColor::RGB.parse("solarized_base03").to_hex).must_equal "#002B36"
		end
		it "Custom names have precedence" do
			_(SimpleColor::RGB.parse("verydarkbluishgreen").to_hex).must_equal "#002A29"
			SimpleColor::RGB.color_names["verydarkbluishgreen"]="#002B30"
			_(SimpleColor::RGB.parse("verydarkbluishgreen").to_hex).must_equal "#002B30"
			_(SimpleColor::RGB.parse("nbs:verydarkbluishgreen").to_hex).must_equal "#002A29"
		end
	end
end

describe SimpleColor do
	after do #restore default options
		SimpleColor.opts=nil
	end

	it "Can parse a true color name" do
		_(SimpleColor.color("foo", "rgb:10-20-30")).must_equal "\e[38;2;10;20;30mfoo\e[0m"
		_(SimpleColor.color("foo", "10-20-30")).must_equal "\e[38;2;10;20;30mfoo\e[0m"
		_(SimpleColor.color("foo", "10:20:30")).must_equal "\e[38;2;10;20;30mfoo\e[0m"
		_(SimpleColor.color("foo", [10, 20, 30])).must_equal "\e[38;2;10;20;30mfoo\e[0m"
	end

	it "Can specify 256 colors" do
		_(SimpleColor.color("foo", "rgb256:1-2-3")).must_equal "\e[38;5;67mfoo\e[0m"
		_(SimpleColor.color("foo", "256:1-2-3")).must_equal "\e[38;5;67mfoo\e[0m"
		_(SimpleColor.color("foo", "256:grey1")).must_equal "\e[38;5;233mfoo\e[0m"
		_(SimpleColor.color("foo", "256:10")).must_equal "\e[38;5;10mfoo\e[0m"
	end

	it "Can specify hexa color name" do
		_(SimpleColor.color("foo", "#10AABB")).must_equal "\e[38;2;16;170;187mfoo\e[0m"
		_(SimpleColor.color("foo", "#1AB")).must_equal "\e[38;2;17;170;187mfoo\e[0m"
	end

	it "Can specify x11 color name" do
		_(SimpleColor.color("foo", "Lemon Chiffon")).must_equal "\e[38;2;255;250;205mfoo\e[0m"
		_(SimpleColor.color("foo", "lemonchiffon")).must_equal "\e[38;2;255;250;205mfoo\e[0m"
	end

	it "Can specify background color name" do
		_(SimpleColor.color("foo", "on_lemonchiffon")).must_equal "\e[48;2;255;250;205mfoo\e[0m"
		_(SimpleColor.color("foo", "on_rgb:255+250+205")).must_equal "\e[48;2;255;250;205mfoo\e[0m"
		_(SimpleColor.color("foo", "on_#CCBBAA")).must_equal "\e[48;2;204;187;170mfoo\e[0m"
		_(SimpleColor.color("foo", "on_rgb256:1+2+3")).must_equal "\e[48;5;67mfoo\e[0m"
		_(SimpleColor.color("foo", "on_rgb256:1")).must_equal "\e[48;5;1mfoo\e[0m"
		_(SimpleColor.color("foo", "on_rgb256:gray1")).must_equal "\e[48;5;233mfoo\e[0m"
		_(SimpleColor.color("foo", [:on, 10, 20, 30])).must_equal "\e[48;2;10;20;30mfoo\e[0m"
	end

	describe "It can fallback to 256 colors" do
		before do
			SimpleColor.color_mode=256
		end

		it "Can specify x11 color name" do
			_(SimpleColor.color("foo", "Lemon Chiffon")).must_equal "\e[38;5;230mfoo\e[0m"
			_(SimpleColor.color("foo", "on_Lemon Chiffon")).must_equal "\e[48;5;230mfoo\e[0m"
		end

		it "Can be forced to be truecolor" do
			_(SimpleColor.color("foo", "t:Lemon Chiffon")).must_equal "\e[38;2;255;250;205mfoo\e[0m"
			_(SimpleColor.color("foo", "truecolor:Lemon Chiffon")).must_equal "\e[38;2;255;250;205mfoo\e[0m"
			_(SimpleColor.color("foo", "true:on_Lemon Chiffon")).must_equal "\e[48;2;255;250;205mfoo\e[0m"
		end
	end

	describe "It can fallback to 8 colors" do
		before do
			SimpleColor.color_mode=8
		end

		it "Can specify x11 color name" do
			_(SimpleColor.color("foo", "Lemon Chiffon")).must_equal "\e[37mfoo\e[0m"
			_(SimpleColor.color("foo", "on_Lemon Chiffon")).must_equal "\e[47mfoo\e[0m"
		end
	end
end
