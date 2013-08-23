module SimpleColor

  COLORS = Hash[[
    [ :clear , 0 ], # String#clear is already used to empty string in Ruby 1.9
    [ :reset , 0 ], # synonym for :clear
    [ :bold , 1 ],
    [ :dark , 2 ],
    [ :italic , 3 ], # not widely implemented
    [ :underline , 4 ],
    [ :underscore , 4 ], # synonym for :underline
    [ :blink , 5 ],
    [ :rapid_blink , 6 ], # not widely implemented
    [ :negative , 7 ], # no reverse because of String#reverse
    [ :concealed , 8 ],
    [ :strikethrough , 9 ], # not widely implemented
    [ :black , 30 ],
    [ :red , 31 ],
    [ :green , 32 ],
    [ :yellow , 33 ],
    [ :blue , 34 ],
    [ :magenta , 35 ],
    [ :cyan , 36 ],
    [ :white , 37 ],
    [ :on_black , 40 ],
    [ :on_red , 41 ],
    [ :on_green , 42 ],
    [ :on_yellow , 43 ],
    [ :on_blue , 44 ],
    [ :on_magenta , 45 ],
    [ :on_cyan , 46 ],
    [ :on_white , 47 ],
    [ :intense_black , 90 ], # High intensity, aixterm (works in OS X)
    [ :intense_red , 91 ],
    [ :intense_green , 92 ],
    [ :intense_yellow , 93 ],
    [ :intense_blue , 94 ],
    [ :intense_magenta , 95 ],
    [ :intense_cyan , 96 ],
    [ :intense_white , 97 ],
    [ :on_intense_black , 100 ], # High intensity background, aixterm (works in OS X)
    [ :on_intense_red , 101 ],
    [ :on_intense_green , 102 ],
    [ :on_intense_yellow , 103 ],
    [ :on_intense_blue , 104 ],
    [ :on_intense_magenta , 105 ],
    [ :on_intense_cyan , 106 ],
    [ :on_intense_white , 107 ]
  ]]

  # Regular expression that is used to scan for ANSI-sequences while
  # uncoloring strings.
  COLORED_REGEXP = /\e\[(?:(?:[349]|10)[0-7]|[0-9])?m/

end
