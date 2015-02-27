require 'simplecolor/version'
require 'simplecolor/colors'

#Usage:
#
#@example
#  class Foo
#		 include SimpleColor::Mixin
#		 def to_str
#			 ...
#		 end
#  end
#  foo=Foo.new()
#  foo.color(:red)

#after SimpleColor.mix_in_string, one can do
#`"blue".color(:blue,:bold)`
module SimpleColor
	# The Colorer module handle all color outputs
	module Colorer
		extend self
		def color_attributes(*args, mode: :text)
			result=args.map {|col| "\e[#{COLORS[col]}m" }.inject(:+)
			if mode == :shell
				return "%{"+result+"%}"
			else
				return result
			end
		end

		def colorer(s,*attributes)
			if s.nil?
				color_attributes(*attributes)
			elsif s.empty?
				s
			else
				matched = s.match(COLOR_REGEXP)
				s.insert(matched.end(0), color_attributes(*attributes))
				s.concat(color_attributes(:clear)) unless s =~ CLEAR_REGEXP
			end
		end
	end

	module ColorWrapper
		extend self

		# Returns an uncolored version of the string, that is all
		# ANSI-sequences are stripped from the string.
		# @see: color
		def uncolor(string = nil)
			if block_given?
				yield.to_str.gsub(COLORED_REGEXP, '')
			elsif string.respond_to?(:to_str)
				string.to_str.gsub(COLORED_REGEXP, '')
			elsif respond_to?(:to_str)
				to_str.gsub(COLORED_REGEXP, '')
			else
				''
			end
		end

		# wrap self or the first argument with colors
		# @example ploum
		#		SimpleColor.color("blue", :blue, :bold)
		#		SimpleColor.color(:blue,:bold) { "blue" }
		#		SimpleColor.color(:blue,:bold) << "blue" << SimpleColor.color(:clear)
		def color(*args)
			if respond_to?(:to_str)
				arg=self.dup
			elsif block_given?
				arg = yield
			elsif args.first.respond_to?(:to_str)
				arg=args.shift
			else
				arg=nil
			end
			Colorer.colorer(arg,*args)
		end
	end
	include ColorWrapper
	extend self

	# enabled can be set to true, false, or :shell
	# :shell means that the color escape sequence will be quoted.
	# This is meant to be used in the shell prompt, so that the escape
	# sequence will not count in the length of the prompt.
	attr_accessor :enabled
	self.enabled=true

	def color(*args)
		super(*args, mode: SimpleColor.enabled) if SimpleColor.enabled
	end
	def uncolor(*args)
		super if SimpleColor.enabled
	end

	module Helpers
		def mix_in(klass)
			klass.send :include, SimpleColor
		end
		def mix_in_string
			mix_in(String)
		end
	end
	extend Helpers
end
