#!/usr/bin/env ruby

require 'simplecolor'
require 'optparse'

args=ARGV.map do |arg|
	if arg.start_with?(':')
		arg[1..-1].to_sym
	else
		arg
	end
end
puts SimpleColor.color(*args)
