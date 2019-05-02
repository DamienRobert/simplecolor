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
		(0..15).each { |i| ANSI_COLORS_16[:"color#{i}"]=i}

		# A list of color names for standard ansi colors, needed for 16/8 color fallback mode
		# See https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
		# These are the xterm color palette
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
			:random => proc { rgb_random },
		}

		module ColorNames
			def color_names
				@color_names ||= COLOR_NAMES.dup
			end

			def all_color_names
				return @rgb_color_names if defined? @rgb_color_names
				# A list of color names, based on X11's rgb.txt
				rgb_colors = File.dirname(__FILE__) + "/../../data/rgb_colors.json.gz"
				# Rewrite file:
				# h={}; rgb.each do |k,v| h[SimpleColor::RGB.rgb_clean(k)]=v end
				# Pathname.new("data/rgb_colors.json").write(h.to_json)
				File.open(rgb_colors, "rb") do |file|
					serialized_data = Zlib::GzipReader.new(file).read
					# serialized_data.force_encoding Encoding::BINARY
					@rgb_color_names = JSON.parse(serialized_data)
				end
			end

			def color_names_priority
				@rgb_color_names.keys
			end

			def rgb_clean(name) #clean up name
				name.gsub(/\s+/,'').downcase.gsub('gray','grey')
			end

			def find_color(name)
				custom=color_names
				case name
				when String
					return custom[name] if custom.key?(name)
					name=rgb_clean(name)
					return custom[name] if custom.key?(name)
					colors=all_color_names
					base, rest=name.split(':', 2)
					if rest.nil?
						color_names_priority.each do |base|
							c=colors[base]
							return c[name] if c.key?(name)
						end
					else
						c=colors[base]
						return c[rest] if c
					end
				else
					custom[name]
				end
			end
		end
		extend ColorNames
	end
end
