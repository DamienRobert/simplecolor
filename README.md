# simplecolor

* [Homepage](https://github.com/DamienRobert/simplecolor)
* [Documentation](http://rubydoc.info/gems/simplecolor)
* [Email](mailto:Damien.Olivier.Robert+gems@gmail.com)

[![Gem Version](https://img.shields.io/gem/v/simplecolor.svg)](https://rubygems.org/gems/simplecolor)
[![Build Status](https://travis-ci.org/DamienRobert/simplecolor.svg?branch=master)](https://travis-ci.org/DamienRobert/simplecolor)

## Description

[rainbow]: https://github.com/sickill/rainbow
[term-ansicolor]: https://github.com/flori/term-ansicolor
[paint]: https://github.com/janlelis/paint

A simple library for coloring text output. Heavily inspired by [rainbow],
[term-ansicolor] and [paint].

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

## Usage

There is a global switch `SimpleColor.enabled` to select the color mode.
The possible values are

- `true`: activate color output
- `false`: desactivate all color output
- `:shell`: activate color output for use in zsh prompt

When using a color escape sequence in a prompt in zsh, zsh will count the
escape sequences as part of the length of a prompt. To mark them as non
printable, one has to wrap them around `%{` and `%}`.
With `SimpleColor.enabled=:shell` this is done automatically by
`SimpleColor`.

## Requirements

None.

## Install

~~~ sh
$ gem install simplecolor
~~~

This installs `v0.1.0`, the current `master` version may not work.

When installing from git, you can regenerate the list of color names by
running `data/rgb_colors.rb`.

## Copyright

Copyright © 2013–2019 Damien Robert

MIT License. See [LICENSE.txt](./LICENSE.txt) for details.
