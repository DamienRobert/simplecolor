module SimpleColor
	ColorerError=Class.new(SimpleColorError)
	WrongColor=Class.new(ColorerError)
	WrongParameter=Class.new(ColorerError)

	# The Colorer module handle all color outputs
	module Colorer
		extend self
		def colors
			COLORS
		end
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
		def color_attributes(*args, mode: :text, colormode: :truecolor, shortcuts: {}, **rgb_parse_opts)
			return "" if mode==:disabled or mode==false #early abort
			shortcuts={} if shortcuts.nil?
			colors=self.colors
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
					raise WrongColor.new(col) unless colors.key?(col)
					accu<< colors[col]
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
						accu << RGB.parse(string, **rgb_parse_opts).ansi(background: !!on, convert: lcolormode)
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
			when :text, :enabled, true
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
end
