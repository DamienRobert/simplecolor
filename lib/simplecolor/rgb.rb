# rgb color conversion
# taken from the paint gem, all copyright belong to its author

module SimpleColor
	module RGBHelper
		extend self

		# If not true_color, creates a 256-compatible color from rgb values,
		# otherwise, an exact 24-bit color
		def rgb(red, green, blue, background = false)
			case @mode
			when 8
				"#{background ? 4 : 3}#{rgb_to_ansi(red, green, blue, false)}"
			when 16
				"#{background ? 4 : 3}#{rgb_to_ansi(red, green, blue, true)}"
			when 256
				"#{background ? 48 : 38}#{rgb_to_256(red, green, blue)}"
			when TRUE_COLOR
				"#{background ? 48 : 38}#{rgb_true(red, green, blue)}"
			end
		end

		# Returns closest supported 256-color an RGB value, without fore-/background information
		# Inspired by the rainbow gem
		def rgb_to_256(red, green, blue, approx = true)
			return ";2;#{red};#{green};#{blue}" unless approx

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
				";5;#{ 232 + ((red.to_f + green.to_f + blue.to_f)/33).round }"
			else # rgb
				";5;#{ [16, *[red, green, blue].zip([36, 6, 1]).map{ |color, mod|
					(6 * (color.to_f / 256)).to_i * mod
				}].inject(:+) }"
			end
		end

		# Returns best ANSI color matching an RGB value, without fore-/background information
		# See https://mail.python.org/pipermail/python-list/2008-December/1150496.html
		def rgb_to_ansi(red, green, blue, use_bright = false)
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
