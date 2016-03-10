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
		WrongColor=Class.new(StandardError)
		def color_attributes(*args, mode: :text)
			result=args.map do |col|
				case col
				when Symbol
					"\e[#{COLORS[col]}m"
				when COLOR_REGEXP
					col
				else
					raise WrongColor(col)
				end
			end.inject(:+)
			case mode
			when :shell
				"%{"+result+"%}"
			when :disabled
				""
			else
				result
			end
		end

		def colorer(s,*attributes,**kwds)
			if s.nil?
				color_attributes(*attributes,**kwds)
			elsif s.empty?
				s
			else
				matched = s.match(/^#{COLOR_REGEXP}/)
				s.insert(matched.end(0), color_attributes(*attributes,**kwds))
				s.concat(color_attributes(:clear,**kwds)) unless s =~ CLEAR_REGEXP
			end
		end

		def uncolorer(s)
			s.to_str.gsub!(COLOR_REGEXP, '')
		end

		def colored?(s)
			s =~ COLOR_REGEXP
		end
	end

	# Wraps around Colorer to provide useful instance methods
	module ColorWrapper
		extend self

		# Returns an uncolored version of the string, that is all
		# ANSI-sequences are stripped from the string.
		# @see: color
		def uncolor!(string = nil)
			arg=if block_given?
				yield.to_s
			elsif string.respond_to?(:to_str)
				string.to_str
			elsif respond_to?(:to_str)
				self.to_str
			else
				''
			end
			Colorer.uncolorer(arg)
		end

		# wrap self or the first argument with colors
		# @example ploum
		#		SimpleColor.color("blue", :blue, :bold)
		#		SimpleColor.color(:blue,:bold) { "blue" }
		#		SimpleColor.color(:blue,:bold) << "blue" << SimpleColor.color(:clear)
		def color!(*args)
			arg=if block_given?
				yield.to_s
			elsif respond_to?(:to_str)
				self.to_str
			elsif args.first.respond_to?(:to_str)
				args.shift.to_str
			else
				nil
			end
			Colorer.colorer(arg,*args)
		end

		[:color,:uncolor].each do |m|
			define_method m do |*args,&b|
				self.dup.send :"#{m}!",*args,&b
			end
		end

		def color?
			arg=if block_given?
				yield.to_s
			elsif respond_to?(:to_str)
				self.to_str
			elsif args.first.respond_to?(:to_str)
				args.shift.to_str
			else
				nil
			end
			Colorer.colored?(arg)
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

	[:color,:color!].each do |m|
		define_method m do |*args, mode: (SimpleColor.enabled || :disabled), &b|
			super(*args, mode: mode, &b)
		end
	end

	module Helpers
		def mix_in(klass)
			klass.send :include, SimpleColor
		end
		def mix_in_string
			mix_in(String)
		end

		def current_color(s)
				matched = s.match(COLOR_REGEXP)
		end
	end
	extend Helpers
end
