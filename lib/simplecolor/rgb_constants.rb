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
	end
end
