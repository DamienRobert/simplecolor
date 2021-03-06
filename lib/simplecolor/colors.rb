module SimpleColor
	module Colorer

		# Regular expression to scan if there is a clear ANSI effect
		CLEAR = "\e\[0m"
		CLEAR_REGEXP = /\e\[0m/
		# Regular expression that is used to scan for ANSI-sequences
		ANSICOLOR_REGEXP = /\e\[(?:[\d;]*)m/
		COLOR_REGEXP = /#{ANSICOLOR_REGEXP}+/
		COLORMATCH_REGEXP = /#{ANSICOLOR_REGEXP}*/

		#Originally stolen from the paint gem.
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

		ANSI_COLORS_FOREGROUND = Hash[ANSI_COLORS.map {|k,v| [k, 30+v]}]
		ANSI_COLORS_BACKGROUND = Hash[ANSI_COLORS.map {|k,v| [:"on_#{k}", 40+v]}]
		# aixterm (not standard)
		ANSI_COLORS_INTENSE_FOREGROUND = Hash[ANSI_COLORS.map {|k,v| [:"intense_#{k}", 90+v]}]
		ANSI_COLORS_INTENSE_BACKGROUND = Hash[ANSI_COLORS.map {|k,v| [:"on_intense_#{k}", 100+v]}]

		ANSI_EFFECTS = {
			:reset				 => 0,	:nothing				 => 0,	# usually supported
			:clear				 => 0,	:normal					=> 0,  # usually supported
			:bright				 => 1,	:bold						 => 1,	# usually supported
			:faint				 => 2,
			:italic				 => 3,
			:underline		 => 4,													# usually supported
			:blink				 => 5,	:slow_blink			 => 5,
			:rapid_blink	 => 6,
			:inverse       => 7, :reverse => 7, :swap => 7, # usually supported
			:conceal			 => 8,	:hide						 => 8,
			:crossed => 9, :crossed_out => 9,
			:default_font  => 10,
			:font0 => 10, :font1 => 11, :font2 => 12, :font3 => 13, :font4 => 14,
			:font5 => 15, :font6 => 16, :font7 => 17, :font8 => 18, :font9 => 19,
			:fraktur			 => 20,
			:bright_off		 => 21, :bold_off				 => 21, :double_underline => 21,
			:clean				 => 22, :regular => 22, #neither bold or faint
			:italic_off		 => 23, :fraktur_off		 => 23,
			:underline_off => 24,
			:blink_off		 => 25,
			:inverse_off	 => 26, :positive				 => 26,
			:conceal_off	 => 27, :show						 => 27, :reveal						=> 27,
			:crossed_off	 => 29, :crossed_out_off => 29,
			:frame				 => 51, :framed => 51,
			:encircle			 => 52, :encircled => 52,
			:overline			 => 53, :overlined => 53,
			:frame_off		 => 54, :encircle_off		 => 54,
			:framed_off		 => 54, :encircled_off		 => 54,
			:overline_off  => 55, :overlined_off  => 55,
		}

		#attributes that can be specified to the color method
		COLORS = [ANSI_EFFECTS,ANSI_COLORS_FOREGROUND, ANSI_COLORS_BACKGROUND, ANSI_COLORS_INTENSE_FOREGROUND, ANSI_COLORS_INTENSE_BACKGROUND].inject({}){ |a,b| a.merge(b) }
	end
end
