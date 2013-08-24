# simplecolor

* [Homepage](https://github.com/DamienRobert/simplecolor)
* [Gem](https://rubygems.org/gems/simplecolor)
* [Documentation](http://rubydoc.info/gems/simplecolor/frames)
* [Email](mailto:Damien.Olivier.Robert+gems@gmail.com)

## Description

[rainbow]: https://github.com/sickill/rainbow
[term-ansicolor]: https://github.com/flori/term-ansicolor
[paint]: https://github.com/janlelis/paint

A simple library for coloring text output. Heavily inspired by [rainbow],
[term-ansicolor] and [paint]. I recommend using these gems for more complex
coloring needs. 

By default this gem does not change the `String` class, unlike [rainbow]. The
reason I wrote this gem is that when mixed in `String` it only adds two
methods: `color` and `uncolor`. This is the main reason I don't use
[term-ansicolor] which is more powerful, but adds more methods when mixed in.
The gem [paint] is similar to this one, but with more powerful shortcuts
definitions.

## Features

- No string extensions (suitable for library development)

- Mixing the library in `String` only add two methods: `color` and
  `uncolor`.

- Supports setting any effects (although most terminals won’t support it)

- Simple to use


## Examples

~~~ ruby
require 'simplecolor'

SimpleColor.color("blue", :blue, :bold)
SimpleColor.color(:blue,:bold) { "blue" }
SimpleColor.color(:blue,:bold) << "blue" << SimpleColor.color(:clear)

SimpleColor.mix_in_string
"blue".color(:blue,:bold)
"\e[34m\e[1mblue\e[0m".uncolor
~~~

## Requirements

None.

## Install

    $ gem install simplecolor

## Todo

- Support 256 colors
- Tests


## Copyright

Copyright (c) 2013 Damien Robert

MIT License. See {file:LICENSE.txt} for details.
