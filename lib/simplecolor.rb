require 'simplecolor/version'
require 'simplecolor/colors'

#Usage:
#
#@example
# class Foo
# 	include SimpleColor
# 	def to_str
# 		...
# 	end
# end
# foo=Foo.new()
# foo.color(:red)

#after SimpleColor.mix_in_string, one can do
#`"blue".color(:blue,:bold)`
module SimpleColor
	extend self

	# The Colorer module handle all color outputs
	module Colorer
		extend self
		WrongColor=Class.new(StandardError)
		# For RGB, Foreground = "\e[38;5;#{fg}m", Background = "\e[48;5;#{bg}m"

		def color_attributes(*args, mode: :text)
			accu=[]
			buffer=""
			flush=lambda {r=accu.join(";"); accu=[]; r.empty? || r="\e["+r+"m"; buffer<<r} #Note: "\e"="\x1b"
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

		def regexp(type=:color, mode: :text)
			case type
			when :color
				if mode == :shell
					m=regexp(:ansi, mode: mode)
					/#{m}+/
				else
					COLOR_REGEXP
				end
			when :match
				if mode == :shell
					m=regexp(:ansi, mode: mode)
					/#{m}*/
				else
					COLORMATCH_REGEXP
				end
			when :ansi
				if mode == :shell
					/%{#{ANSICOLOR_REGEXP}%}/
				else
					ANSICOLOR_REGEXP
				end
			when :clear
				if mode == :shell
					/%{#{CLEAR_REGEXP}%}/
				else
					CLEAR_REGEXP
				end
			end
		end

		def colorer(s,*attributes,**kwds)
			if s.nil?
				color_attributes(*attributes,**kwds)
			elsif s.empty?
				s
			else
				# we need to insert the ANSI sequences after existing ones so that
				# the new colors have precedence
				matched = s.match(regexp(:match, **kwds))
				attributes=color_attributes(*attributes,**kwds)
				s.insert(matched.end(0), attributes)
				s.concat(color_attributes(:clear,**kwds)) unless s =~ /#{regexp(:clear, **kwds)}$/ or attributes.empty?
				s
			end
		end

		# Returns an uncolored version of the string, that is all
		# ANSI-sequences are stripped from the string.
		# @see: colorer
		def uncolorer(s, **kwds)
			s.to_str.gsub!(regexp(:color, **kwds), '') || s.to_str
		rescue ArgumentError #rescue from "invalid byte sequence in UTF-8"
			s.to_str
		end

		def colored?(s, **kwds)
			!! (s =~ regexp(:color, **kwds))
		end
	end

	# Wraps around Colorer to provide useful instance methods
	module ColorWrapper
		extend self
		# wrap self or the first argument with colors
		# @example ploum
		#		SimpleColor.color("blue", :blue, :bold)
		#		SimpleColor.color(:blue,:bold) { "blue" }
		#		SimpleColor.color(:blue,:bold) << "blue" << SimpleColor.color(:clear)
		%i(color! uncolor! color?).each do |m|
			define_method m do |*args, &b|
				arg=if b
					b.call.to_s
				elsif respond_to?(:to_str)
					self.to_str
				elsif args.first.respond_to?(:to_str)
					args.shift.to_str
				else
					nil
				end
				case m
				when :color!
					Colorer.colorer(arg,*args)
				when :uncolor!
					Colorer.uncolorer(arg,*args)
				when :color?
					Colorer.colored?(arg,*args)
				end
			end
		end

		[:color,:uncolor].each do |m|
			define_method m do |*args,&b|
				self.dup.send :"#{m}!",*args,&b
			end
		end
	end

	module Helpers
		extend self

		def mix_in(klass)
			klass.send :include, SimpleColor
		end
		def mix_in_string
			mix_in(String)
		end

		# scan s from left to right and for each ansi sequences found
		# split it into elementary components and output the symbolic meaning
		# eg: SimpleColor.attributes_from_colors(SimpleColor.color("foo", :red))
		#     => [:red, :reset]
		def attributes_from_colors(s)
			s.scan(/#{ANSICOLOR_REGEXP}/).flat_map do |a|
				next :reset if a=="\e[m"
				a[/\e\[(.*)m/,1].split(';').map {|c| COLORS.key(c.to_i)}
			end
		end

		#get the ansi sequences on s (assume the whole line is colored)
		#returns left_ansi, right_ansi, string
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

		def color_module(mod)
			class << mod
				attr_accessor :enabled
			end
			mod.enabled=true

			coloring=Module.new do
				# enabled can be set to true, false, or :shell
				# :shell means that the color escape sequence will be quoted.
				# This is meant to be used in the shell prompt, so that the escape
				# sequence will not count in the length of the prompt.
				include ColorWrapper

				[:color,:color!, :uncolor, :uncolor!, :color?].each do |m|
					define_method m do |*args, mode: (mod.enabled || :disabled), &b|
						super(*args, mode: mode, &b)
					end
				end
			end
			mod.include(coloring)
			mod.extend(coloring)
			mod.extend(Helpers)
		end
	end

	Helpers.color_module(self)
end
