require 'simplecolor/version'
require 'simplecolor/colors'

#Usage:
#
#@example
# class Foo
#		include SimpleColor
#		def to_str
#			...
#		end
# end
# foo=Foo.new()
# foo.color(:red)

#after SimpleColor.mix_in_string, one can do
#`"blue".color(:blue,:bold)`
module SimpleColor
	SimpleColorError=Class.new(StandardError)

	require 'simplecolor/colorer'
	require 'simplecolor/rgb'

	# Wraps around Colorer to provide useful instance methods
	module ColorWrapper
		extend self
		# wrap self or the first argument with colors
		# @example ploum
		#		SimpleColor.color("blue", :blue, :bold)
		#		SimpleColor.color(:blue,:bold) { "blue" }
		#		SimpleColor.color(:blue,:bold) << "blue" << SimpleColor.color(:clear)
		%i(color uncolor color! uncolor! color?).each do |m|
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
				when :color
					Colorer.colorer(arg.dup,*args)
				when :uncolor
					Colorer.uncolorer(arg.dup,*args)
				when :color!
					Colorer.colorer(arg,*args)
				when :uncolor!
					Colorer.uncolorer(arg,*args)
				when :color?
					Colorer.colored?(arg,*args)
				end
			end
		end
	end

	module Utilities
		extend self

		# scan s from left to right and for each ansi sequences found
		# split it into elementary components and output the symbolic meaning
		# eg: SimpleColor.attributes_from_colors(SimpleColor.color("foo", :red))
		#			=> [:red, :reset]
		def attributes_from_colors(s)
			s.scan(Colorer.regexp(:ansi)).flat_map do |a|
				next :reset if a=="\e[m" #alternative for reset
				a[/\e\[(.*)m/,1].split(';').map {|c| Colorer.colors.key(c.to_i)}
			end
		end

		#get the ansi sequences on s (assume the whole line is colored)
		#returns left_ansi, right_ansi, string
		def current_colors(s)
			m=s.match(/^(#{Colorer.regexp(:match)})(.*?)(#{Colorer.regexp(:match)})$/)
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
		def color_entities(l, color_regexp: Colorer.regexp(:color))
			l.split(/(#{color_regexp})/).flat_map {|c| color?(c) ? [c] : c.split('') }
		end
		#same as above but split into strings
		def color_strings(l, color_regexp: Colorer.regexp(:color))
			u=l.split(/(#{color_regexp})/)
			# if we start with an ANSI sequence, u is ["", ...], so we need to
			# get rid of that ""
			u.shift if u.first == ""
			u
		end

		def fill(s, columns:ENV['COLUMNS']&.to_i || 80)
			r=s.each_line.map do |l|
				l=l.chomp
				length=uncolor(l).length
				to_fill=columns - (length % columns)
				to_fill = 0 if to_fill == columns
				l+" "*to_fill
			end.join("\n")
			r+="\n" if s.end_with?("\n")
			r
		end

		def clear
			color(:clear)
		end
	end

	module Opts
		extend self

		@default_abbreviations={}
		@default_colornames={}
		@default_opts={mode: true, color_mode: :truecolor, abbreviations: @default_abbreviations}
		class << self
			attr_reader :default_opts, :default_colornames
		end

		attr_writer :opts
		def opts
			@opts ||= Opts.default_opts.clone
		end

		# enabled can be set to true, false, or :shell
		# :shell means that the color escape sequence will be quoted.
		# This is meant to be used in the shell prompt, so that the escape
		# sequence will not count in the length of the prompt.
		opts_access={enabled: :mode}
		%i(mode color_mode abbreviations).each do |opt|
			opts_access[opt]=opt
		end
		opts_access.each do |i,k|
			define_method(i) do
				opts[k]
			end
			define_method("#{i}=".to_sym) do |v|
				opts[k]=v
			end
		end
	end

	module Mixin
		def self.define_color_methods(klass, *methods, opts_from: nil, color_module: ColorWrapper)
			methods=color_module.instance_methods if methods.empty?
			methods.each do |m|
				klass.define_method m do |*args, **l_opts, &b|
					opts= opts_from ? opts_from.opts : self.opts
					opts=opts.merge(l_opts)
					color_module.instance_method(m).bind(self).call(*args, **opts, &b)
				end
			end
		end

		def mixin(*methods)
			klass=self
			Module.new do
				Mixin.define_color_methods(self, *methods, opts_from: klass)
			end
		end

		def mix_in(klass)
			klass.send :include, mixin
		end
		def mix_in_string
			mix_in(String)
		end
	end

	include Utilities
	include Opts
	include Mixin
	extend self

	Mixin.define_color_methods(self)
end
