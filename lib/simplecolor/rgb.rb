require 'json'
require "zlib"

# rgb color conversion
# taken from the paint gem, all copyright belong to its author

module SimpleColor
	RGBError=Class.new(SimpleColorError)
	WrongRGBColor=Class.new(RGBError)
	WrongRGBParameter=Class.new(RGBError)

	class RGB
		require 'simplecolor/rgb_constants'

		module Parsers
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

			def parse(col, color_names: proc {|c| self.find_color(c)})
				case col
				when self
					col
				when Symbol
					raise WrongRGBColor.new(col) unless ANSI_COLORS_16.key?(col)
					self.new(col, mode: 16)
				when Array
					self.new(col, mode: true)
				when String
					if (m=col.match(/\A(?:rgb)?256[+:-]?(?<grey>gr[ae]y)?(?<red>\d+)(?:[+:-](?<green>\d+)[+:-](?<blue>\d+))?\z/))
						grey=m[:grey]; red=m[:red]&.to_i; green=m[:green]&.to_i; blue=m[:blue]&.to_i
						if grey
							self.new(GREY256+red, mode: 256)
						elsif green and blue
							self.new([red, green, blue], mode: 256)
						else
							raise WrongRGBColor.new(col) if green
							self.new(red, mode: 256)
						end
					elsif (m=col.match(/\A(?:rgb[+:-]?)?(?<red>\d+)[+:-](?<green>\d+)[+:-](?<blue>\d+)\z/))
						red=m[:red]&.to_i; green=m[:green]&.to_i; blue=m[:blue]&.to_i
						self.new([red, green, blue], mode: :truecolor)
					elsif (m=col.match(/\A#?(?<hex_color>[[:xdigit:]]{3}{1,2})\z/)) # 3 or 6 hex chars
						self.new(rgb_hex(m[:hex_color]), mode: :truecolor)
					else
						if color_names && (c=color_names[col])
							self.parse(c, color_names: nil)
						else
							raise WrongRGBColor.new(col)
						end
					end
				end
			end
		end
		extend Parsers

		module Utils
			def rgb_random
				RGB.new((1..3).map { Random.rand(256) })
			end
			
			#c=16 + 36 × r + 6 × g + b
			def color256_to_rgb(c)
				(c-16).digits(6)
			end

			def rgb_values(c)
				case c
				when self
					c.to_truecolor.color
				else
					self.parse(c).to_truecolor.color
				end
			end

			def list_color_names
				return @rgb_color_names if defined? @rgb_color_names
				rgb_colors = File.dirname(__FILE__) + "/../../data/rgb_colors.json.gz"
				# A list of color names, based on X11's rgb.txt

				# Rewrite file:
				# h={}; SimpleColor::RGB_COLORS.each do |k,v| h[SimpleColor::RGB.rgb_name(k)]=v end
				# Pathname.new("data/rgb_colors.json").write(h.to_json)
				File.open(rgb_colors, "rb") do |file|
					serialized_data = Zlib::GzipReader.new(file).read
					# serialized_data.force_encoding Encoding::BINARY
					@rgb_color_names = JSON.parse(serialized_data)
				end
				@rgb_color_names
			end

			def rgb_name(name) #clean up name
				name.gsub(/\s+/,'').downcase
			end

			def find_color(name)
				if name == "random"
					return rgb_random
				end
				cleaned=rgb_name(name)
				list_color_names[cleaned]
			end
		end

		extend Utils

		attr_accessor :color, :mode

		private def color_mode(mode)
			case mode
			when true, :truecolor, TRUE_COLOR
				mode=:truecolor
			end
			case mode
			when 8, 16, 256, :truecolor
				yield mode if block_given?
				return mode
			else
				raise WrongRGBParameter.new(mode)
			end
		end

		def initialize(*rgb, mode: :truecolor)
			raise WrongRGBColor.new(rgb) if rgb.empty?
			rgb=rgb.first if rgb.length==1
			raise WrongRGBColor.new(rgb) if rgb.nil?

			@init=rgb
			@color=rgb #should be an array for truecolor, a number otherwise
			@mode=color_mode(mode)
			
			case @mode
			when :truecolor
				unless @color&.size == 3 && @color&.all?{ |n| n.is_a? Numeric }
					raise WrongRGBColor.new(rgb)
				end
				raise WrongRGBColor.new(rgb) unless rgb.all? do |c|
					(0..255).include?(c)
				end
			when 256 #for 256 colors we are more lenient
				case rgb
				when Array
					unless @color&.size == 3 && @color&.all?{ |n| n.is_a? Numeric }
						raise WrongRGBColor.new(rgb)
					end
					raise WrongRGBColor.new(rgb) unless rgb.all? do |c|
						(0..5).include?(c)
					end
					red, green, blue=rgb
					@color=16 + 36 * red.to_i + 6 * green.to_i + blue.to_i
				when String, Symbol #for grey mode
					if (m=rgb.to_s.match(/\Agr[ae]y(\d+)\z/))
						@color=GREY256+m[1].to_i
					else
						raise WrongRGBColor.new(rgb)
					end
				else
					raise WrongRGBColor.new(rgb) unless @color.is_a?(Numeric)
				end
			when 8,16
				@color=ANSI_COLORS_16[rgb] if ANSI_COLORS_16.key?(rgb)
				raise WrongRGBColor.new(rgb) unless @color.is_a?(Numeric)
			end
			# TODO raise when wrong color passed
		end

		def truecolor?
			@mode == :truecolor
		end

		def nbcolors
			return TRUE_COLOR if @mode == :truecolor
			return @mode
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
		def ansi(background: false, convert: nil)
			return self.convert(convert, only_down: true).ansi(background: background, convert: nil) if convert
			case @mode
			when 8, 16
				"#{background ? 4 : 3}#{@color}"
			when 256
				"#{background ? 48 : 38};5;#{@color}"
			when :truecolor
				red, green, blue=@color
				"#{background ? 48 : 38};2;#{red};#{green};#{blue}"
			end
		end

		def convert(mode, only_down: false)
			case color_mode(mode)
			when 8
				return to_8
			when 16
				return to_16 unless only_down and nbcolors < 16
			when 256
				return to_256 unless only_down and nbcolors < 256
			when :truecolor
				return to_truecolor unless only_down and nbcolors < TRUE_COLOR
			end
			self
		end

		def rgb_color_distance(rgb2)
			if truecolor?
				@color.zip(self.class.rgb_values(rgb2)).inject(0){ |acc, (cur1, cur2)| acc + (cur1 - cur2)**2 }
			else
				to_truecolor.rgb_color_distance(rgb2)
			end
		end

		def rgb_to_pool(color_pool)
			if truecolor?
				color_pool.min_by{ |col| rgb_color_distance(col) }
			else
				to_truecolor.rgb_to_pool(color_pool)
			end
		end

		def to_truecolor
			case @mode
			when 8, 16
				name=RGB_COLORS_ANSI_16.key(@color)
				self.class.new(ANSI_COLORS_16[name])
			when 256
				if @color < 16
					to_16.to_truecolor
				elsif @color < GREY256
					red, green, blue=self.class.color256_to_rgb(@color)
					self.class.new([red, green, blue].map {|c| (c * 256.0/7.0).round})
				else
					grey=@color-GREY256
					self.class.new([(grey*256.0/24.0).round]*3)
				end
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
				red,green,blue=@color

				gray_possible = true
				sep = 42.5

				while gray_possible
					if red < sep || green < sep || blue < sep
						gray = red < sep && green < sep && blue < sep
						gray_possible = false
					end
					sep += 42.5
				end

				col=if gray
					GREY256 + ((red.to_f + green.to_f + blue.to_f)/33).round
				else # rgb
					[16, *[red, green, blue].zip([36, 6, 1]).map{ |color, mod|
						(6 * (color.to_f / 256)).to_i * mod
					}].inject(:+)
				end
				self.class.new(col, mode: 256)

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
