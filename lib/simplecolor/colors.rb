module SimpleColor

	# Number of possible colors in TRUE COLOR mode
	TRUE_COLOR = 0xFFFFFF

	# Regular expression to scan if there is a clear ANSI effect
	CLEAR = "\e\[0m"
	CLEAR_REGEXP = /\e\[0m/
	# Regular expression that is used to scan for ANSI-sequences
	ANSICOLOR_REGEXP = /\e\[(?:[\d;]*)m/
	COLOR_REGEXP = /#{ANSICOLOR_REGEXP}+/
	COLORMATCH_REGEXP = /#{ANSICOLOR_REGEXP}*/

	#Stolen from the paint gem.
	#See also http://en.wikipedia.org/wiki/ANSI_escape_code

	# Basic colors (often, the color differs when using the bright effect)
	# Final color will be 30 + value for foreground and 40 + value for background
	# 90+value for intense foreground, 100+value for intense background
	ANSI_COLORS = {
		:black	 => 0,
		:red		 => 1,
		:green	 => 2,
		:yellow  => 3,
		:blue		 => 4,
		:magenta => 5,
		:cyan		 => 6,
		:white	 => 7,
		:default => 9,
	}
	
	ANSI_EFFECTS = {
		:reset				 => 0,	:nothing				 => 0,	# usually supported
		:clear				 => 0,	:normal					=> 0,  # usually supported
		:bright				 => 1,	:bold						 => 1,	# usually supported
		:faint				 => 2,
		:italic				 => 3,
		:underline		 => 4,													# usually supported
		:blink				 => 5,	:slow_blink			 => 5,
		:rapid_blink	 => 6,
		:inverse			 => 7,	:swap						 => 7,	# usually supported
		:conceal			 => 8,	:hide						 => 9,
		:default_font  => 10,
		:font0 => 10, :font1 => 11, :font2 => 12, :font3 => 13, :font4 => 14,
		:font5 => 15, :font6 => 16, :font7 => 17, :font8 => 18, :font9 => 19,
		:fraktur			 => 20,
		:bright_off		 => 21, :bold_off				 => 21, :double_underline => 21,
		:clean				 => 22,
		:italic_off		 => 23, :fraktur_off		 => 23,
		:underline_off => 24,
		:blink_off		 => 25,
		:inverse_off	 => 26, :positive				 => 26,
		:conceal_off	 => 27, :show						 => 27, :reveal						=> 27,
		:crossed_off	 => 29, :crossed_out_off => 29,
		:frame				 => 51,
		:encircle			 => 52,
		:overline			 => 53,
		:frame_off		 => 54, :encircle_off		 => 54,
		:overline_off  => 55,
	}

	ANSI_COLORS_FOREGROUND = {
		:black	 => 30,
		:red		 => 31,
		:green	 => 32,
		:yellow  => 33,
		:blue		 => 34,
		:magenta => 35,
		:cyan		 => 36,
		:white	 => 37,
		:default => 39,
	}

	ANSI_COLORS_BACKGROUND = {
		:on_black		=> 40,
		:on_red			=> 41,
		:on_green		=> 42,
		:on_yellow	=> 43,
		:on_blue		=> 44,
		:on_magenta => 45,
		:on_cyan		=> 46,
		:on_white		=> 47,
		:on_default => 49,
	}

	ANSI_COLORS_INTENSE_FOREGROUND = {
		:intense_black	 => 90,
		:intense_red		 => 91,
		:intense_green	 => 92,
		:intense_yellow  => 93,
		:intense_blue		 => 94,
		:intense_magenta => 95,
		:intense_cyan		 => 96,
		:intense_white	 => 97,
		:intense_default => 99,
	}

	ANSI_COLORS_INTENSE_BACKGROUND = {
		:on_intense_black		=> 100,
		:on_intense_red			=> 101,
		:on_intense_green		=> 102,
		:on_intense_yellow	=> 103,
		:on_intense_blue		=> 104,
		:on_intense_magenta => 105,
		:on_intense_cyan		=> 106,
		:on_intense_white		=> 107,
		:on_intense_default => 109,
	}

	#attributes that can be specified to the color method
	COLORS = [ANSI_EFFECTS,ANSI_COLORS_FOREGROUND, ANSI_COLORS_BACKGROUND, ANSI_COLORS_INTENSE_FOREGROUND, ANSI_COLORS_INTENSE_BACKGROUND].inject({}){ |a,b| a.merge(b) }

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

end
