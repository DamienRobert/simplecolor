require 'json'
require "zlib"

# rgb color conversion
# taken from the paint gem, all copyright belong to its author

module SimpleColor
	rgb_colors = File.dirname(__FILE__) + "/../../data/rgb_colors.json.gz"
	# A list of color names, based on X11's rgb.txt

	# Rewrite file:
	# h={}; SimpleColor::RGB_COLORS.each do |k,v| h[SimpleColor::RGB.rgb_name(k)]=v end
	# Pathname.new("data/rgb_colors.json").write(h.to_json)
	File.open(rgb_colors, "rb") do |file|
		serialized_data = Zlib::GzipReader.new(file).read
		# serialized_data.force_encoding Encoding::BINARY
		RGB_COLORS = JSON.parse(serialized_data)
	end

	# A list of color names for standard ansi colors, needed for 16/8 color fallback mode
	# See https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
	RGB_COLORS_ANSI = {
		:black	 => [  0,		0,	 0],
		:red		 => [205,		0,	 0],
		:green	 => [  0, 205,	 0],
		:yellow  => [205, 205,	 0],
		:blue		 => [  0,		0, 238],
		:magenta => [205,		0, 205],
		:cyan		 => [  0, 205, 205],
		:white	 => [229, 229, 229],
		:gray => [229, 229, 229],
	}.each { |_k, v| v.freeze }.freeze

	# A list of color names for standard bright ansi colors, needed for 16 color fallback mode
	# See https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
	RGB_COLORS_ANSI_BRIGHT = {
		:intense_black	 => [127, 127, 127],
		:intense_red		 => [255,		0,	 0],
		:intense_green	 => [  0, 255,	 0],
		:intense_yellow  => [255, 255,	 0],
		:intense_blue		 => [ 92,  92, 255],
		:intense_magenta => [255,		0, 255],
		:intense_cyan		 => [  0, 255, 255],
		:intense_white	 => [255, 255, 255],
		:intense_gray => [255, 255, 255],
	}.each { |_k, v| v.freeze }.freeze

	RGB_COLORS_ANSI_16 = RGB_COLORS_ANSI.merge(RGB_COLORS_ANSI_BRIGHT)

	class RGB2
		module Parsers
			def rgb_name(name) #clean up name
				name.gsub(/\s+/,'').downcase
			end
			# Creates RGB color from a HTML-like color definition string
			def rgb_hex(string)
				case string.size
				when 6
					string.each_char.each_slice(2).map{ |hex_color| hex_color.join.to_i(16) }
				when 3
					string.each_char.map{ |hex_color_half| (hex_color_half*2).to_i(16) }
				else
					raise WrongRGBColor.new(string)
				end
			end

			def parse(col, color_names: {})
				case col
				when Symbol
					raise WrongColor.new(col) unless ANSI_COLORS_16.key?(col)
					self.new(col, mode: 16)
				when Array
					self.new(col, mode: true)
				when String
					if (m=col.match(/\A(?:rgb)?256[+:-]?(?<grey>gr[ae]y)?(?<red>\d+)(?:[+:-](?<green>\d+)[+:-](?<blue>\d+))?\z/))
						grey=m[:grey]; red=m[:red]; green=m[:green]; blue=m[:blue]
						if grey
							self.new(232+red, mode: 256)
						elsif green and blue
							self.new([red, green, blue], mode: 256)
						else
							raise WrongRGBColor.new(col) if green
							self.new(red, mode: 256)
						end
					elsif (m=col.match(/\A(?:rgb[+:-]?)?(?<red>\d+)[+:-](?<green>\d+)[+:-](?<blue>\d+)\z/))
						red=m[:red]; green=m[:green]; blue=m[:blue]
						self.new([red, green, blue], mode: :truecolor)
					elsif (m=col.match(/\A#?(?<hex_color>[[:xdigit:]]{3}{1,2})\z/)) # 3 or 6 hex chars
						self.new(rgb_hex(m[:hex_color]), mode: :truecolor)
					else
						cleaned=rgb_name(string)
						if color_names.key?(cleaned)
							self.new(color_names[cleaned], mode: :truecolor)
						else
							raise WrongRGBColor.new(col)
						end
					end
				end
			end
		end
		extend Parsers

		module Utils
			def rgb_random(background: false)
				(background ? [:on] : []) + (1..3).map { Random.rand(256) }
			end
		end
		extend Utils

		attr_accessor :color, :mode
		def initialize(rgb, mode: true)
			@init=rgb
			@color=rgb #should be an array for truecolor, a number otherwise
			case mode
			when 8, 16, 256
				@mode=mode
			when true, :truecolor, 0xFFFFFF
				@mode=:truecolor
			else
				raise WrongRGBParameter.new(mode)
			end
			
			case @mode
			when 256 #for 256 colors we are more lenient
				case rgb
				when Array
					red, green, blue=rgb
					@color=16 + 36 * red.to_i + 6 * green.to_i + blue.to_i
				when String, Symbol #for grey mode
					if (m=rgb.to_s.match(/\Agr[ae]y(\d+)\z/))
						@color=232+m[1].to_i
					else
						raise WrongRGBColorName.new(rgb)
					end
				else
					raise WrongRGBColorName.new(rgb)
				end
			when 8,16
				@color=ANSI_COLORS_16[rgb] if ANSI_COLORS_16.key?(rgb)
			end
			# TODO raise when wront error passed
		end

		def truecolor?
			@mode == :truecolor
		end

		# For RGB 256 colors,
		# Foreground = "\e[38;5;#{fg}m", Background = "\e[48;5;#{bg}m"
		# where the color code is
		# 0-	7:	standard colors (as in ESC [ 30–37 m)
		# 8- 15:	high intensity colors (as in ESC [ 90–97 m)
		# 16-231:  6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (0 ≤ r, g, b ≤ 5)
		#232-255:  grayscale from black to white in 24 steps

		#For true colors:
		#		ESC[ 38;2;<r>;<g>;<b> m Select RGB foreground color
		#		ESC[ 48;2;<r>;<g>;<b> m Select RGB background color
		def to_ansi(background: false)
			case @mode
			when 8, 16
				"#{background ? 4 : 3}#{@color}"
			when 256
				"#{background ? 48 : 38}#{@color}"
			when :truecolor
				red, green, blue=@color
				"#{background ? 48 : 38};2;#{red};#{green};#{blue}"
			end
		end

		def rgb_color_distance(rgb2)
			if truecolor?
				@color.zip(rgb2.to_truecolor).inject(0){ |acc, (cur1, cur2)| acc + (cur1 - cur2)**2 }
			else
				to_truecolor.rgb_color_distance(rgb2)
			end
		end

		def rgb_to_pool(color_pool)
			if truecolor?
				color_pool.min_by{ |col| rgb_color_distance([red, green, blue],col) }
			else
				to_truecolor.rgb_to_pool(color_pool)
			end
		end

		def to_truecolor
			case @mode
			when 8, 16
				name=ANSI_COLORS_16.key(@color)
				self.class.new(RGB_COLORS_ANSI_16[name])
			when 256
				self #todo
			else
				self
			end
		end

		def to_256
			case @mode
			when 256
				return self
			when 8, 16
				return self.class.new(@color, mode: 256)
			else
				gray_possible = true
				sep = 42.5

				while gray_possible
					if red < sep || green < sep || blue < sep
						gray = red < sep && green < sep && blue < sep
						gray_possible = false
					end
					sep += 42.5
				end

				if gray
					232 + ((red.to_f + green.to_f + blue.to_f)/33).round
				else # rgb
					[16, *[red, green, blue].zip([36, 6, 1]).map{ |color, mod|
						(6 * (color.to_f / 256)).to_i * mod
					}].inject(:+)
				end
			end
		end

		def to_8
			color_pool = RGB_COLORS_ANSI.values
			closest=rgb_to_pool(color_pool)
			name=RGB_COLORS_ANSI.key(closest)
			self.class.new(ANSI_COLORS_16[name], mode: 8)
		end

		def to_16
			color_pool = RGB_COLORS_ANSI_16.values
			closest=rgb_to_pool(color_pool)
			name=RGB_COLORS_ANSI_16.key(closest)
			self.class.new(ANSI_COLORS_16[name], mode: 16)
		end
	end
end
