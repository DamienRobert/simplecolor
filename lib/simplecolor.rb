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
	extend self
	SimpleColorError=Class.new(StandardError)
	ColorerError=Class.new(SimpleColorError)
	WrongColor=Class.new(ColorerError)
	WrongParameter=Class.new(ColorerError)
	require 'simplecolor/rgb'

	# The Colorer module handle all color outputs
	module Colorer
		extend self

		# A color name can be:
		# - an array of rgb data (truecolor)
		#		(start with :on to specify background)
		# - a String:
		#			rgb:10-20-30 (foreground truecolor)
		#			on_rgb:10-20-30 (background truecolor)
		#			t:rgb... (don't fallback to lower color mode)
		#			(on_)rgb256:r:g:b  (force 256 color mode)
		#			(on_)rgb256:grey3 (256 grey scale)
		#			(on_)rgb256:5 (direct color code)
		#			(t:)(on_)#AABBCC (hex code, truecolor)
		#			(t:)(on_)#ABC (reduced hex code, truecolor)
		#			(t:)(on_)name (X11 color name, truecolor)
		# A color attribute can be:
		# - a symbol (looked in at COLORS)
		# - an integer (direct color code)
		# - a color escape sequence
		# - a String
		def color_attributes(*args, mode: :text, colormode: :truecolor, shortcuts: {}, colornames: RGB_COLORS)
			return "" if mode==:disabled or mode==false #early abort
			shortcuts={} if shortcuts.nil?
			accu=[]
			buffer=""
			flush=lambda {r=accu.join(";"); accu=[]; r.empty? || r="\e["+r+"m"; buffer<<r} #Note: "\e"="\x1b"
			args.each do |col|
				if shortcuts.key?(col)
					scol=*shortcuts[col]
					# Array are special, in a non shortcut they mean an rgb mode but for shortcuts it just combine several color attributes
					buffer << color_attributes(*scol, mode: mode, colormode: colormode, shortcuts: {}) #we erase shortcuts so :red = :red do not get an infinite loop
					next
				end
				case col
				when Proc
					scol=*col.call(buffer, accu)
					buffer << color_attributes(*scol, mode: mode, colormode: colormode, shortcuts: shortcuts)
				when Symbol
					raise WrongColor.new(col) unless COLORS.key?(col)
					accu<<COLORS[col]
				when Integer #direct ansi code
					accu << col.to_s
				when Array
					background=false
					if col.first == :on
						background=true; col.shift
					end
					accu << RGB.new(col).ansi(convert: colormode, background: background)
				when COLOR_REGEXP
					flush.call
					buffer<<col
				when String
					truecol=/(?<truecol>(?:truecolor|true|t):)?/
					on=/(?<on>on_)?/
					col.match(/\A#{truecol}#{on}(?<rest>.*)\z/) do |m|
						tcol=m[:truecol]; on=m[:on]; string=m[:rest]
						tcol ? lcolormode=:truecolor : lcolormode=colormode
						accu << RGB.parse(string, color_names: colornames).ansi(background: !!on, convert: lcolormode)
					end
				when nil # skip
				else
					raise WrongColor.new(col)
				end
			end
			flush.call

			case mode
			when :shell
				"%{"+buffer+"%}"
			when :disabled
				"" # already handled above
			when :enabled, true
				buffer
			else
				raise WrongParameter.new(mode)
			end
		end

		def regexp(type=:color, mode: :text, **_rest)
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

		# Returns a colored version of the string (modified in place),
		# according to attributes
		def colorer(s,*attributes,**kwds)
			if s.nil?
				color_attributes(*attributes,**kwds)
			elsif s.empty?
				# We don't color an empty string; use nil to get color attributes
				s
			else
				# we need to insert the ANSI sequences after existing ones so that
				# the new colors have precedence
				matched = s.match(regexp(:match, **kwds)) #since this has a '*' it matches at the beginning
				attributes=color_attributes(*attributes,**kwds)
				s.insert(matched.end(0), attributes)
				s.concat(color_attributes(:clear,**kwds)) unless s =~ /#{regexp(:clear, **kwds)}$/ or attributes.empty?
				s
			end
		end

		def colorer2
				color_reg=regexp(:color, **kwds)
				clear_reg=regexp(:clear, **kwds)
				colors=color_attributes(*attributes,**kwds)
				clear=color_attributes(:clear,**kwds)
				pos=0

				split=SimpleColor.color_strings(s, color_regexp: color_reg)
				first=split.first
				split.shift
				if first&.match(color_reg)
					pos+=first.length
					s.insert(pos, colors)
					pos+=colors.length
				end
				split.each do |sp|
					if sp.match(/#{clear_reg}$/)
						pos+=sp.length
						s.insert(pos, colors)
					end
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
			s.scan(/#{ANSICOLOR_REGEXP}/).flat_map do |a|
				next :reset if a=="\e[m" #alternative for reset
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
		def color_entities(l, color_regexp: COLOR_REGEXP)
			l.split(/(#{color_regexp})/).flat_map {|c| color?(c) ? [c] : c.split('') }
		end
		#same as above but split into strings
		def color_strings(l, color_regexp: COLOR_REGEXP)
			u=l.split(/(#{color_regexp})/)
			# if we start with an ANSI sequence, u is ["", ...], so we need to
			# get rid of that ""
			u.shift if u.first == ""
			u
		end
	end

	module Helpers
		extend self
		Shortcuts={ random: proc { [RGB.rgb_random] },
			on_random: proc { [RGB.rgb_random(background: true)]},
		}
		ColorNames=RGB_COLORS.merge({
			"solarized_base03" =>		"#002b36",
			"solarized_base02" =>  "#073642",
			"solarized_base01" =>  "#586e75",
			"solarized_base00" =>  "#657b83",
			"solarized_base0"  => "#839496",
			"solarized_base1"  => "#93a1a1",
			"solarized_base2"  => "#eee8d5",
			"solarized_base3"  => "#fdf6e3",
			"solarized_yellow" => "#b58900",
			"solarized_orange" => "#cb4b16",
			"solarized_red"		 => "#dc322f",
			"solarized_magenta"=> "#d33682",
			"solarized_violet" => "#6c71c4",
			"solarized_blue"	 => "#268bd2",
			"solarized_cyan"	 => "#2aa198",
			"solarized_green"  => "#859900",
		})
		DefaultOpts={mode: true, colormode: :truecolor, shortcuts: Shortcuts, colornames: ColorNames}

		def mix_in(klass)
			klass.send :include, SimpleColor
		end
		def mix_in_string
			mix_in(String)
		end

		def color_module(mod=nil)
			mod=Module.new if mod.nil?

			class << mod
				attr_accessor :opts
				{enabled: :mode, mode: :mode, color_mode: :colormode, color_names: :colornames, abbreviations: :shortcuts}.each do |i,k|
					define_method(i) do
						opts[k]
					end
					define_method("#{i}=".to_sym) do |v|
						opts[k]=v
					end
				end
			end
			#copy caller's options
			dopts= respond_to?(:opts) ? opts : DefaultOpts
			# mod.opts=Marshal.load(Marshal.dump(dopts)) #deep clone?
			mod.opts=dopts.clone

			coloring=Module.new do
				# enabled can be set to true, false, or :shell
				# :shell means that the color escape sequence will be quoted.
				# This is meant to be used in the shell prompt, so that the escape
				# sequence will not count in the length of the prompt.
				include ColorWrapper

				ColorWrapper.instance_methods.each do |m|
					define_method m do |*args, **opts, &b|
						opts=mod.opts.merge(opts)
						super(*args, **opts, &b)
					end
				end
			end
			mod.include(coloring)
			mod.extend(coloring)
			# mod.extend(Helpers)
			mod
		end
	end

	extend Utilities
	extend Helpers
	Helpers.color_module(self)
end
