#!/usr/bin/env ruby

require 'simplecolor/mixin'
require 'optparse'

def showcase
	empty="  "
	lorem="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

	puts "* 16 colors:"
	print "8 colors: "
	%w(black red green yellow blue magenta cyan white).each do |s|
		print SimpleColor.color(s, s.to_sym); print " "
	end
	puts

	print "8 colors bold: "
	%w(black red green yellow blue magenta cyan white).each do |s|
		print SimpleColor.color(s, s.to_sym, :bold); print " "
	end
	puts

	print "8 intense colors: "
	%w(black red green yellow blue magenta cyan white).each do |s|
		print SimpleColor.color(s, "intense_#{s}".to_sym); print " "
	end
	puts

	print "8 intense colors bold: "
	%w(black red green yellow blue magenta cyan white).each do |s|
		print SimpleColor.color(s, "intense_#{s}".to_sym, :bold); print " "
	end
	puts
	puts
	
	print "8 colors on black: "
	%w(black red green yellow blue magenta cyan white).each do |s|
		print SimpleColor.color(s, s.to_sym, :on_black); print " "
	end
	puts
	print "8 colors on white: "
	%w(black red green yellow blue magenta cyan white).each do |s|
		print SimpleColor.color(s, s.to_sym, :on_white); print " "
	end
	puts
	puts

	puts "System palette:"
	(40..47).each do |color|
		print SimpleColor.color(empty, color)
	end
	print "  =  "
	%w(black red green yellow blue magenta cyan white).each do |s|
		print SimpleColor.color(empty, "on_#{s}".to_sym);
	end
	# puts (:bold does not change the background color)
	# (40..47).each do |color|
	# 	print SimpleColor.color(empty, color, :bold)
	# end
	puts #not supported on vte
	(90..97).each do |color|
		print SimpleColor.color(empty, color)
	end
	puts
	puts

	puts "* 256 colors:"
	puts "System palette:";
	(0..7).each do |color|
		print SimpleColor.color(empty, "on_rgb256:#{color}")
	end
	puts
	(8..15).each do |color|
		print SimpleColor.color(empty, "on_rgb256:#{color}")
	end
	puts

	rgb_cube = ->(&b) do
		for green in 0..5 do
			for red in 0..5 do
				for blue in 0..5 do
					b.call [red, green, blue]
				end 
				print " "
			end
			puts
		end
	end
	puts
	puts "Color cube, 6x6x6:"
	rgb_cube.call do |red, green, blue|
		print SimpleColor.color(empty, "on_rgb256:#{red}:#{green}:#{blue}")
	end
	puts
	puts "Grayscale ramp:"
	(0..23).each do |color|
		print SimpleColor.color(empty, "on_rgb256:grey#{color}")
	end
	puts
	puts
	puts "Color cube code:"
	rgb_cube.call do |red, green, blue|
		print SimpleColor.color("#{red}#{green}#{blue}", "rgb256:#{red}:#{green}:#{blue}"); print(" ")
	end
	puts
	puts "Color cube code (bold):"
	rgb_cube.call do |red, green, blue|
		print SimpleColor.color("#{red}#{green}#{blue}", "rgb256:#{red}:#{green}:#{blue}", :bold); print(" ")
	end

	puts
	puts "* Truecolor:"
	puts SimpleColor.color(SimpleColor.fill("Lemon Chiffon on Lavender"), "Lemon Chiffon", "on_Lavender")
	puts

	puts "- Random color:"
	lorem.each_char {|c| print SimpleColor.color(:random)+c}
	print SimpleColor.clear
	puts
	puts "- Random color on random background:"
	lorem.each_char {|c| print SimpleColor.color(:random, :on_random)+c}
	print SimpleColor.clear
	puts

	puts
	print "Solarized on light background: ".color("solarized_base00", "on_solarized_base3")
	%w(yellow orange red magenta violet blue cyan green).each do |col|
		print "#{col} ".color("solarized_#{col}", "on_solarized_base3")
	end
	puts
	print "Solarized on dark background: ".color("solarized_base0", "on_solarized_base03")
	%w(yellow orange red magenta violet blue cyan green).each do |col|
		print "#{col} ".color("solarized_#{col}", "on_solarized_base03")
	end
	puts
	[3, 2, 1, 0].each do |on|
		(0..3).each do |cin|
			puts SimpleColor.fill("Solarized color base0#{cin} on base#{on}").color("solarized_base0#{cin}", "on_solarized_base#{on}")
		end
	end
	[3, 2, 1, 0].each do |on|
		(0..3).each do |cin|
			puts SimpleColor.fill("Solarized color base#{cin} on base0#{on}").color("solarized_base#{cin}", "on_solarized_base0#{on}")
		end
	end
end

optparse = OptionParser.new do |opt|
	opt.on("--color=number", "-c", "Set number of colors", Integer) do |v|
		SimpleColor.color_mode=v
	end
	opt.on("--showcase", "Showcase color capabilities of terminal") do |_v|
		showcase
	end
end
optparse.parse!

args=ARGV.map do |arg|
	if arg.start_with?(':')
		arg[1..-1].to_sym
	else
		arg
	end
end
puts SimpleColor.color(*args)
