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
			accu=[]
			buffer=""
			flush=lambda {r=accu.join(";"); accu=[]; r.empty? || r="\e["+r+"m"; buffer<<r}
			args.each do |col|
				case col
				when Symbol
					raise WrongColor.new(col) unless COLORS.key?(col)
					accu<<COLORS[col]
				when COLOR_REGEXP
					flush.call
					buffer<<col
				else
					raise WrongColor.new(col)
				end
			end
			flush.call
			case mode
			when :shell
				"%{"+buffer+"%}"
			when :disabled
				""
			else
				buffer
			end
		end

		def colorer(s,*attributes,**kwds)
			if s.nil?
				color_attributes(*attributes,**kwds)
			elsif s.empty?
				s
			else
				matched = s.match(COLORMATCH_REGEXP)
				attributes=color_attributes(*attributes,**kwds)
				s.insert(matched.end(0), attributes)
				s.concat(color_attributes(:clear,**kwds)) unless s =~ /#{CLEAR_REGEXP}$/ or attributes.empty?
				s
			end
		end

		def uncolorer(s)
			s.to_str.gsub!(COLOR_REGEXP, '') || s.to_str
		rescue ArgumentError #rescue from "invalid byte sequence in UTF-8"
			s.to_str
		end

		def colored?(s)
			!! (s =~ COLOR_REGEXP)
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

		def color?(*args)
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

		def attributes_from_colors(s)
			s.scan(/#{ANSICOLOR_REGEXP}/).flat_map do |a|
				next :reset if a=="\e[m"
				a[/\e\[(.*)m/,1].split(';').map {|c| COLORS.key(c.to_i)}
			end
		end
		#get the ansi sequences on s (assume the whole line is colored)
		def current_colors(s)
			m=s.match(/^(#{COLORMATCH_REGEXP})(.*?)(#{COLORMATCH_REGEXP})$/)
			[m[1],m[3],m[2]]
		rescue ArgumentError #rescue from "invalid byte sequence in UTF-8"
			["","",s]
		end
		#copy the colors from s to t
		def copy_colors(s,t)
			b,e=current_colors(s)
			b+t+e
		end
		#split the line into characters and ANSII color sequences
		def color_entities(l)
			l.split(/(#{COLOR_REGEXP})/).flat_map {|c| color?(c) ? [c] : c.split('') }
		end
	end
	extend Helpers
end
