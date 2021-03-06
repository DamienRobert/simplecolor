#!/usr/bin/env ruby

require 'simplecolor/mixin'
require 'optparse'

def solarized
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

	print "Background system palette:"
	%w(black red green yellow blue magenta cyan white).each do |s|
		print SimpleColor.color(empty, "on_#{s}".to_sym);
	end
	## This is simply:
	# (40..47).each do |color|
	# 	print SimpleColor.color(empty, color)
	# end
	## (:bold does not change the background color)
	# (40..47).each do |color|
	# 	print SimpleColor.color(empty, color, :bold)
	# end
	puts
	print "High intensity background system palette:"
	(90..97).each do |color|
		print SimpleColor.color(empty, color)
	end
	puts
	puts

	print SimpleColor[:red, :on_blue]
	print "Red on blue "
	print SimpleColor[:default]
	print "back to default foreground "
	print SimpleColor[:on_default]
	print "back to default background."
	puts
	puts
	names=%w(black red green yellow blue magenta cyan white)
	names+=names.map {|i| "intense_#{i}"}
	columns=ENV['COLUMN']&.to_i || 80 
	(0..15).each do |i|
		color=names[i]
		rgb=SimpleColor::RGB.new(i, mode: 16)
		printf "Color%02d = %s %-30s %s\n".color(color.to_sym), i, rgb.to_hex, color, (" "*(columns-49)).color("on_#{color}".to_sym)
	end
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
	cube= ->(start, to_end) do
		direction=(0..2).map {|i| to_end[i]-start[i]}
		(0..255).each do |v|
			rgb=(0..2).map {|i| start[i]*255 + v*direction[i]}
			print SimpleColor.color(empty, SimpleColor::RGB.new(rgb, background: true))
		end
	end
	print_cube = ->(*steps) do
		print "Cube #{steps.map {|s| s.join}.join(" to ")}: "
		(0...steps.length-1).each do |i|
			cube[steps[i], steps[i+1]]
			print " "
		end
		puts
	end
	print_cube[[0,0,0],[1,1,1]]

	print_cube[[0,0,0],[1,0,0],[1,1,1]]
	print_cube[[0,0,0],[0,1,0],[1,1,1]]
	print_cube[[0,0,0],[0,0,1],[1,1,1]]

	print_cube[[0,0,0],[0,1,1],[1,1,1]]
	print_cube[[0,0,0],[1,0,1],[1,1,1]]
	print_cube[[0,0,0],[1,1,0],[1,1,1]]

	print_cube[[1,0,0],[1,1,0], [0,1,0]]

	print_cube[[1,0,0],[1,0,1], [0,0,1]]

	print_cube[[0,1,0],[0,1,1], [0,0,1]]

	puts
	puts "* Effects"
	effects=SimpleColor::Colorer::ANSI_EFFECTS
	effects.values.uniq.each do |v|
		eff=effects.each_key.map { |k| effects[k]==v ? k : nil }.compact
		before_effect=eff.find {|e| e=~/_off/}&.to_s&.sub('_off','')&.to_sym
		if before_effect
			puts "- #{eff.join('/')}: " + "lorem".color(before_effect)+ " ipsum".color(v)
		else
			puts "- #{eff.join('/')}: " + "lorem ipsum".color(v)
		end
	end

	puts
	puts "* Terminfo effects"
	print "- Italic: "; system('tput sitm'); print "lorem ipsum"; system('tput ritm')
end

optparse = OptionParser.new do |opt|
	opt.on("--color=number", "-c", "Set number of colors", Integer) do |v|
		SimpleColor.color_mode=v
	end
	opt.on("--showcase", "-s", "Showcase color capabilities of terminal") do |_v|
		showcase
	end
	opt.on("--solarized", "Show solarized colors") do |_v|
		solarized
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
