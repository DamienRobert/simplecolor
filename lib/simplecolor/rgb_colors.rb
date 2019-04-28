module SimpleColor
	class RGB
		GREY256=232
		TRUE_COLOR=0xFFFFFF

		ANSI_COLORS_16 = {
			:black	 => 0,
			:red		 => 1,
			:green	 => 2,
			:yellow  => 3,
			:blue		 => 4,
			:magenta => 5,
			:cyan		 => 6,
			:white	 => 7,
			:intense_black	 => 8,
			:intense_red		 => 9,
			:intense_green	 => 10,
			:intense_yellow  => 11,
			:intense_blue		 => 12,
			:intense_magenta => 13,
			:intense_cyan		 => 14,
			:intense_white	 => 15,
		}

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

		COLOR_NAMES={
			"solarized_base03"	=> "#002b36",
			"solarized_base02"	=> "#073642",
			"solarized_base01"	=> "#586e75",
			"solarized_base00"	=> "#657b83",
			"solarized_base0"		=> "#839496",
			"solarized_base1"		=> "#93a1a1",
			"solarized_base2"		=> "#eee8d5",
			"solarized_base3"		=> "#fdf6e3",
			"solarized_yellow"	=> "#b58900",
			"solarized_orange"	=> "#cb4b16",
			"solarized_red"			=> "#dc322f",
			"solarized_magenta" => "#d33682",
			"solarized_violet"	=> "#6c71c4",
			"solarized_blue"		=> "#268bd2",
			"solarized_cyan"		=> "#2aa198",
			"solarized_green"		=> "#859900",
		}

		module ColorNames
			def custom_color_names
				COLOR_NAMES
			end

			def color_names
				return @rgb_color_names if defined? @rgb_color_names
				# A list of color names, based on X11's rgb.txt
				rgb_colors = File.dirname(__FILE__) + "/../../data/rgb_colors.json.gz"
				# Rewrite file:
				# h={}; SimpleColor::RGB_COLORS.each do |k,v| h[SimpleColor::RGB.rgb_name(k)]=v end
				# Pathname.new("data/rgb_colors.json").write(h.to_json)
				File.open(rgb_colors, "rb") do |file|
					serialized_data = Zlib::GzipReader.new(file).read
					# serialized_data.force_encoding Encoding::BINARY
					@rgb_color_names = JSON.parse(serialized_data)
				end
				@rgb_color_names.merge!(custom_color_names)
			end

			def rgb_clean(name) #clean up name
				name.gsub(/\s+/,'').downcase
			end

			def find_color(name)
				if name == "random"
					return rgb_random
				end
				cleaned=rgb_clean(name)
				color_names[cleaned]
			end
		end
		extend ColorNames
	end
end
