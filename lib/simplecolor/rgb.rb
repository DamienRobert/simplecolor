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
		:black	 => [127, 127, 127],
		:red		 => [255,		0,	 0],
		:green	 => [  0, 255,	 0],
		:yellow  => [255, 255,	 0],
		:blue		 => [ 92,  92, 255],
		:magenta => [255,		0, 255],
		:cyan		 => [  0, 255, 255],
		:white	 => [255, 255, 255],
		:gray => [255, 255, 255],
	}.each { |_k, v| v.freeze }.freeze


	module RGB
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

		WrongRGBColorParameter=Class.new(StandardError)
		extend self

		def rgb_random
		end

		def rgb_name(name) #clean up name
			name.gsub(/\s+/,'').downcase
		end

		# If not true_color, creates a 256-compatible color from rgb values,
		# otherwise, an exact 24-bit color
		def rgb(red, green, blue, background: false, mode: :truecolor)
			case mode
			when 8
				"#{background ? 4 : 3}#{rgb_to_ansi(red, green, blue, use_bright: false)}"
			when 16
				"#{background ? 4 : 3}#{rgb_to_ansi(red, green, blue, use_bright: true)}"
			when 256
				"#{background ? 48 : 38}#{rgb_to_256(red, green, blue)}"
			when TRUE_COLOR, :truecolor, true
				"#{background ? 48 : 38}#{rgb_true(red, green, blue)}"
			else
				raise WrongRGBColorParameter.new(mode)
			end
		end

		# Creates RGB color from a HTML-like color definition string
		def rgb_hex(string, **opts)
			case string.size
			when 6
				color_code = string.each_char.each_slice(2).map{ |hex_color| hex_color.join.to_i(16) }
			when 3
				color_code = string.each_char.map{ |hex_color_half| (hex_color_half*2).to_i(16) }
			end
			rgb(*color_code, **opts)
		end

		def rgb256(red, green, blue, background: false)
			rgb=16 + 36 * red.to_i + 6 * green.to_i + blue.to_i
			"#{background ? 48 : 38};5;#{rgb}"
		end
		def grey256(grey, background: false)
			grey=232+grey.to_i
			"#{background ? 48 : 38};5;#{grey}"
		end
		def direct256(code, background: false)
			"#{background ? 48 : 38};5;#{code}"
		end

		# Returns 24-bit color value (see https://gist.github.com/XVilka/8346728)
		# in ANSI escape sequnce format, without fore-/background information
		def rgb_true(red, green, blue)
			";2;#{red};#{green};#{blue}"
		end

		# Returns closest supported 256-color an RGB value, without fore-/background information
		# Inspired by the rainbow gem
		def rgb_to_256(red, green, blue)
			gray_possible = true
			sep = 42.5

			while gray_possible
				if red < sep || green < sep || blue < sep #todo: to_f
					gray = red < sep && green < sep && blue < sep
					gray_possible = false
				end
				sep += 42.5
			end

			if gray
				";5;#{ 232 + ((red.to_f + green.to_f + blue.to_f)/33).round }"
			else # rgb
				";5;#{ [16, *[red, green, blue].zip([36, 6, 1]).map{ |color, mod|
					(6 * (color.to_f / 256)).to_i * mod
				}].inject(:+) }"
			end
		end

		# Returns best ANSI color matching an RGB value, without fore-/background information
		# See https://mail.python.org/pipermail/python-list/2008-December/1150496.html
		def rgb_to_ansi(red, green, blue, use_bright: false)
			color_pool =	RGB_COLORS_ANSI.values
			color_pool += RGB_COLORS_ANSI_BRIGHT.values if use_bright

			ansi_color_rgb = color_pool.min_by{ |col| rgb_color_distance([red, green, blue],col) }
			if ansi_color = RGB_COLORS_ANSI.key(ansi_color_rgb)
				ANSI_COLORS[ansi_color]
			else
				ansi_color = RGB_COLORS_ANSI_BRIGHT.key(ansi_color_rgb)
				"#{ANSI_COLORS[ansi_color]};1"
			end
		end

		def rgb_color_distance(rgb1, rgb2)
			rgb1.zip(rgb2).inject(0){ |acc, (cur1, cur2)|
				acc + (cur1 - cur2)**2
			}
		end
	end
end
