== Release v0.4.0 (2020-02-26) ==

	* Fix ruby 2.3 bug
	* Fix a truffleruby bug
	* Fix minitest warnings
	* Add rgb_colors.json.gz
	* Support old ruby versions
	* Update for ruby 2.7
	* Add todo
	* bin/simplecolor: showcase now show more about the base colors

== Release v0.3.0 (2019-05-02) ==

	* Update Readme
	* color schemes: move to data/
	* Add tests for color names
	* Add lots of color names
	* More tests
	* Add tests for local_color/global_color
	* Replace colorer by colorer2
	* colorer2: bug fixes
	* colorer2: better global color detection
	* colorer2
	* Add test
	* attributes_from_colors: support 256 and truecolors
	* SimpleColor[]
	* Add :color0 ... :color15
	* RGB: fix color conversion
	* Abstract 8/16 color palette
	* Rgb color names can by symbols
	* Effects
	* RGB: can specify default @background
	* RGB.to_hex
	* Rename rgb_constants to rgb_colors
	* SimpleColor.fill
	* Color names: use a constant
	* RGB: custom color names
	* Color names
	* Random: this is a rgb color rather than an abbreviation
	* colorer: better recursive handling
	* Change names of options
	* Put Colorer in its own fle
	* Rework the way we construct mixins
	* Move constants around
	* Color names: use a Proc
	* Fixing all tests!
	* Use constants
	* More bug fixes
	* Misc bug fixes
	* Use new RGB class
	* Class RGB
	* Begin new RGB class
	* New key: colornames
	* Showcase + solarized shortcut
	* Bug fixes + tests
	* bin: --color=number
	* Add binary
	* Correctly dup arg
	* proc in color: return multiple values
	* Small tweak
	* Test proc
	* Add :random, :on_random shortcuts
	* test: simplify resetting default options
	* rgb color: support background mode with Array
	* color_module: copy current options
	* Shortcuts: be more general
	* Fix test
	* Shortcuts
	* tests
	* Color names: switch to json data
	* Improve regexp
	* Fixes for 256 colors
	* Add Hex mode
	* Raise when passed non supported parameters
	* Add color_mode parameter
	* 256 colors
	* Continue rgb handling
	* Update Rakefile
	* Rakefile: add mapping
	* Update Rakefile
	* Add rgb.rb, from the paint gem
	* Preliminary for truecolor support
	* SimpleColor.color_strings
	* color_module: shortcuts
	* Add tests
	* Generate new coloring module
	* enabled should be a singleton method
	* Add tests
	* uncolor, color?: work in shell mode
	* Add mixin.rb to help mix in String
	* Copyright
	* Whitespace

== Release v0.2.0 (2017-02-20) ==

	* Add minitest dependency
	* Fix binary strings
	* Correct a bug on uncolor when there was no colors
	* attribute_from_colors
	* Bugfixes
	* Better color regexps
	* Bug fixes
	* Mix attributes and ANSI strings
	* Color entities and add tests
	* Typos
	* function to handle existing colors
	* Concatenate ANSI escape sequences inside the \e
	* Add possibility to copy colors
	* Sometimes \e[m is abused for \e[0m
	* More exceptions
	* Merge some color regexp and raise exception on bogus colors
	* Fix SimpleColor#uncolor!
	* Change ANSI Regexps
	* rake doc fails for now with Rake 11
	* Add uncolor tests
	* ColorWrapper: unify gestion of arg
	* Correct a bug in uncolor
	* Add more tests
	* Add color! and uncolor!
	* Specify mode even when nothing is passed
	* Add color?
	* Add more tests
	* Split the module into small unit modules
	* Add warning to use v0.1.0
	* First step to add a Colorer class
	* typo
	* Put simplecolor.rb in lib/ rather than lib/simplecolor/
	* Improve documentation
	* Describe SimpleColor.enabled
	* sh code block
	* README: use code block
	* Adding a simple test
	* Shortcut for mixing in class
	* Update homepage

== Release v0.1.0 (2013-08-23) ==

	* Add more ANSI effects
	* Update documentation
	* First public version
	* Initial commit.

