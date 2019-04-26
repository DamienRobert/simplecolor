require 'helper'
require 'simplecolor'

class TestSimpleColor < MiniTest::Test

	def test_version
		version = SimpleColor.const_get('VERSION')

		assert(!version.empty?, 'should have a VERSION constant')
	end

end

describe SimpleColor do
	after do #restore default options
		SimpleColor.opts=SimpleColor::Helpers::DefaultOpts.clone
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
		SimpleColor.color("red",:inverse,"\e[31m",:blue,:bold).must_equal "\e[7m\e[31m\e[34;1mred\e[0m"
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

	it "uncolor does not change uncolored strings" do
		SimpleColor.uncolor("red").must_equal "red"
	end

	it "Can detect colored strings" do
		SimpleColor.color?("red").must_equal false
		SimpleColor.color?(SimpleColor.color("red",:red)).must_equal true
	end

	it "Can only show color escape when passed nil" do
		SimpleColor.color(nil, "lavender").must_equal "\e[38;2;230;230;250m"
	end

	it "Accepts a block as color parameter" do
		SimpleColor.color("foo", proc { "lavender" }).must_equal "\e[38;2;230;230;250mfoo\e[0m"
	end

	it "Proc as color parameter can return multiple values" do
		SimpleColor.color("foo", proc { ["lavender", :bold] }).must_equal "\e[38;2;230;230;250;1mfoo\e[0m"
	end

	it "Has default options" do
		SimpleColor.opts.must_equal(SimpleColor::Helpers::DefaultOpts)
	end

	describe "Shortcuts" do
		before do
			SimpleColor.color_names={red: SimpleColor.color(:green), color1: SimpleColor.color(nil, "lavender")}
		end

		it "Can use the color1 shortcut" do
			SimpleColor.color("foo", :color1).must_equal "\e[38;2;230;230;250mfoo\e[0m"
		end
		it "Shortcuts have precedence" do
			SimpleColor.color("foo", :red).must_equal SimpleColor.color("foo", :green)
		end
	end

	describe "Default shortcuts" do
		it "Has a default :random shortcut" do
			SimpleColor.color("foo", :random).must_match(/\e\[38;2;\d+;\d+;\d+mfoo\e\[0m/)
		end
		it "Has a default :on_random shortcut" do
			SimpleColor.color("foo", :on_random).must_match(/\e\[48;2;\d+;\d+;\d+mfoo\e\[0m/)
		end
	end

	describe "Shell mode" do
		before do
			SimpleColor.enabled=:shell
		end

		it "Wraps color into shell escapes" do
			SimpleColor.color("red",:red).must_equal "%{\e[31m%}red%{\e[0m%}"
		end

		it "Can uncolor correctly" do
			SimpleColor.uncolor(SimpleColor.color("red",:red)).must_equal "red"
		end

		it "Only uncolor shell wrapped colors" do
			red="\e[31mred\e[0m"
			SimpleColor.uncolor(red).must_equal red
		end

		it "Can detect colors correctly" do
			SimpleColor.color?(SimpleColor.color("red",:red)).must_equal true
		end

		it "Only detect shell wrapped colors" do
			SimpleColor.color?("\e[31mred\e[0m").must_equal false
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
			s.uncolor
			s.must_equal "\e[31mred\e[0m"
		end

		it "uncolor! does not affects the string" do
			s="\e[31mred\e[0m"
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
			b,e=SimpleColor.current_colors(SimpleColor.color("red",:red,:bold))
			SimpleColor.attributes_from_colors("\e[m"+b+e).must_equal([:reset,:red,:bright,:reset])
		end

		it "Can split a string into color entities" do
			SimpleColor.color_entities(SimpleColor.color("red",:red,:bold)+SimpleColor.color("blue",:blue)).must_equal(["\e[31;1m", "r", "e", "d", "\e[0m\e[34m", "b", "l", "u", "e", "\e[0m"])
			SimpleColor.color_entities("blue "+SimpleColor.color("red",:red,:bold)+" green").must_equal(["b", "l", "u", "e", " ", "\e[31;1m", "r", "e", "d", "\e[0m", " ", "g", "r", "e", "e", "n"])
		end

		it "Can split a string into color strings" do
			SimpleColor.color_strings(SimpleColor.color("red",:red,:bold)+SimpleColor.color("blue",:blue)).must_equal(["\e[31;1m", "red", "\e[0m\e[34m", "blue", "\e[0m"])
			SimpleColor.color_strings("blue "+SimpleColor.color("red",:red,:bold)+" green").must_equal(["blue ", "\e[31;1m", "red", "\e[0m", " green"])
		end
	end

	describe "It can use a different color module" do
		module SimpleColor2
		end
		SimpleColor.color_module(SimpleColor2)

		it "Can color too" do
			SimpleColor2.color("red", :red).must_equal "\e[31mred\e[0m"
		end

		it "Still works if SimpleColor is disabled" do
			SimpleColor.enabled=false
			SimpleColor2.color("red", :red).must_equal "\e[31mred\e[0m"
			SimpleColor.color("red", :red).must_equal "red"
		end

		it "Can be disabled without disabling SimpleColor" do
			SimpleColor2.enabled=false
			SimpleColor.color("red", :red).must_equal "\e[31mred\e[0m"
			SimpleColor2.color("red", :red).must_equal "red"
			SimpleColor2.enabled=true
		end
	end

	describe "It can use a different color module via inclusion" do
		module SimpleColor3
			extend SimpleColor.color_module
		end

		it "Can color too" do
			SimpleColor3.color("red", :red).must_equal "\e[31mred\e[0m"
		end

		it "In this case can't change :enabled" do
			SimpleColor3.respond_to?(:enabled).must_equal false
		end
	end

	describe "Setting a different color module copy the defaults opts" do
		module SimpleColor4
		end
		old_opts=SimpleColor.opts
		SimpleColor.opts={mode: false, colormode: 16}
		SimpleColor.color_module(SimpleColor4)
		SimpleColor.opts=old_opts

		it "Has the same defaults as when created" do
			SimpleColor4.opts.must_equal({mode: false, colormode: 16})
		end

		it "Changing the opts afterwards do not affect it" do
			SimpleColor4.enabled=true
			SimpleColor4.opts.must_equal({mode: true, colormode: 16})
			SimpleColor.opts.must_equal(SimpleColor::Helpers::DefaultOpts)
			SimpleColor4.enabled=false
		end
	end
end
