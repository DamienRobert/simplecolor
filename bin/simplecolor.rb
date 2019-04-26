#!/usr/bin/env ruby

require 'simplecolor'
require 'optparse'

optparse = OptionParser.new do |opt|
	opt.on("--color=number", "-c", "Set number of colors", Integer) do |v|
		SimpleColor.color_mode=v
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
