require 'helper'
require 'simplecolor'

describe SimpleColor::RGB do
	it "Should output truecolor code" do
		SimpleColor::RGB.rgb(10,20,30).must_equal "38;2;10;20;30"
	end
	it "Can degrade to 256 colors" do
		SimpleColor::RGB.rgb(10,20,30, mode: 256).must_equal "38;5;234"
	end
	it "Can degrade to 16 colors" do
		SimpleColor::RGB.rgb(10,20,160, mode: 16).must_equal "34"
	end
	it "Can degrade to 8 colors" do
		SimpleColor::RGB.rgb(10,20,30, mode: 8).must_equal "30"
	end
end

describe SimpleColor do
	it "Can parse a true color name" do
		SimpleColor.color("foo", "rgb:10-20-30").must_equal "\e[38;2;10;20;30mfoo\e[0m"
		SimpleColor.color("foo", "10-20-30").must_equal "\e[38;2;10;20;30mfoo\e[0m"
		SimpleColor.color("foo", "10:20:30").must_equal "\e[38;2;10;20;30mfoo\e[0m"
	end

	it "Can specify 256 colors" do
		SimpleColor.color("foo", "rgb256:1-2-3").must_equal "\e[38;5;67mfoo\e[0m"
		SimpleColor.color("foo", "256:1-2-3").must_equal "\e[38;5;67mfoo\e[0m"
		SimpleColor.color("foo", "256:grey1").must_equal "\e[38;5;233mfoo\e[0m"
		SimpleColor.color("foo", "256:10").must_equal "\e[38;5;10mfoo\e[0m"
	end

	it "Can specify hexa color name" do
		SimpleColor.color("foo", "#10AABB").must_equal "\e[38;2;16;170;187mfoo\e[0m"
		SimpleColor.color("foo", "#1AB").must_equal "\e[38;2;17;170;187mfoo\e[0m"
	end

	it "Can specify x11 color name" do
		SimpleColor.color("foo", "Lemon Chiffon").must_equal "\e[38;2;255;250;205mfoo\e[0m"
		SimpleColor.color("foo", "lemonchiffon").must_equal "\e[38;2;255;250;205mfoo\e[0m"
	end

	it "Can specify background color name" do
		SimpleColor.color("foo", "on_lemonchiffon").must_equal "\e[48;2;255;250;205mfoo\e[0m"
		SimpleColor.color("foo", "on_rgb:255+250+205").must_equal "\e[48;2;255;250;205mfoo\e[0m"
		SimpleColor.color("foo", "on_#CCBBAA").must_equal "\e[48;2;204;187;170mfoo\e[0m"
		SimpleColor.color("foo", "on_rgb256:1+2+3").must_equal "\e[48;5;67mfoo\e[0m"
		SimpleColor.color("foo", "on_rgb256:1").must_equal "\e[48;5;1mfoo\e[0m"
		SimpleColor.color("foo", "on_rgb256:gray1").must_equal "\e[48;5;233mfoo\e[0m"
	end

	describe "It can fallback to 256 colors" do
		before do
			SimpleColor.color_mode=256
		end
		after do
			SimpleColor.color_mode=true
		end

		it "Can specify x11 color name" do
			SimpleColor.color("foo", "Lemon Chiffon").must_equal "\e[38;5;230mfoo\e[0m"
			SimpleColor.color("foo", "on_Lemon Chiffon").must_equal "\e[48;5;230mfoo\e[0m"
		end

		it "Can be forced to be truecolor" do
			SimpleColor.color("foo", "t:Lemon Chiffon").must_equal "\e[38;2;255;250;205mfoo\e[0m"
			SimpleColor.color("foo", "truecolor:Lemon Chiffon").must_equal "\e[38;2;255;250;205mfoo\e[0m"
			SimpleColor.color("foo", "true:on_Lemon Chiffon").must_equal "\e[48;2;255;250;205mfoo\e[0m"
		end
	end

	describe "It can fallback to 8 colors" do
		before do
			SimpleColor.color_mode=8
		end
		after do
			SimpleColor.color_mode=true
		end

		it "Can specify x11 color name" do
			SimpleColor.color("foo", "Lemon Chiffon").must_equal "\e[37mfoo\e[0m"
			SimpleColor.color("foo", "on_Lemon Chiffon").must_equal "\e[47mfoo\e[0m"
		end
	end
end
