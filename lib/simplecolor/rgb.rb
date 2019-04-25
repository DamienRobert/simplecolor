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

	module RGB
		WrongRGBColorParameter=Class.new(StandardError)
		extend self

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
