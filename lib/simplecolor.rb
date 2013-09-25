require 'simplecolor/version'
require 'simplecolor/colors'

module SimpleColor
  # The Colorer class allows to enable/disable coloring on a global level.
  # By instancing this class, you can have a more fine grained control on
  # which part of coloring is activated.
  class Colorer

    # enabled can be set to true, false, or :shell
    # :shell means that the color escape sequence will be quoted.
    # This is meant to be used in the shell prompt, so that the escape
    # sequence will not count in the length of the prompt.
    attr_accessor :enabled
    def initialize
      enabled=true
    end

    def colorattributes(*args)
      if enabled
        result=args.map {|col| "\e[#{COLORS[col]}m" }.inject(:+)
        if enabled == :shell
          return "%{"+result+"%}"
        else
          return result
        end
      else
        return ''
      end
    end

    # creates a module that can then be mixed in a class to provide color
    # output
    def mixin_module

      # Returns an uncolored version of the string, that is all
      # ANSI-sequences are stripped from the string.
      # @see: color
      def uncolor(string = nil)
        if block_given?
          yield.to_str.gsub(COLORED_REGEXP, '')
        elsif string.respond_to?(:to_str)
          string.to_str.gsub(COLORED_REGEXP, '')
        elsif respond_to?(:to_str)
          to_str.gsub(COLORED_REGEXP, '')
        else
          ''
        end
      end

      # wrap self or the first argument with colors
      # @example ploum
      #   SimpleColor.color("blue", :blue, :bold)
      #   SimpleColor.color(:blue,:bold) { "blue" }
      #   SimpleColor.color(:blue,:bold) << "blue" << SimpleColor.color(:clear)
      def color(*args)
        if respond_to?(:to_str)
          arg=self.dup
        elsif block_given?
          arg = yield
        elsif args.first.respond_to?(:to_str)
          arg=args.shift
        else
          arg=nil
        end
        return arg unless SimpleColor.enabled

        if arg.nil?
          return SimpleColor.colorattributes(*args)
        elsif arg.empty?
          return arg
        else
          matched = arg.match(SimpleColor::COLOR_REGEXP)
          arg.insert(matched.end(0), SimpleColor.colorattributes(*args))
          arg.concat(SimpleColor.colorattributes(:clear)) unless arg =~ SimpleColor::CLEAR_REGEXP
          return arg
        end
      end
    end

    def mixin(klass)
    end
  end
  self.enabled=true


  #Usage:
  #
  #@example
  #  class Foo
  #    include SimpleColor::Mixin
  #    def to_str
  #      ...
  #    end
  #  end
  #  foo=Foo.new()
  #  foo.color(:red)

  #after SimpleColor.mix_in_string, one can do
  #`"blue".color(:blue,:bold)`
  include SimpleColor::Mixin
  def mix_in(klass)
    klass.class_eval {include SimpleColor::Mixin}
  end
  def mix_in_string
    SimpleColor.mix_in(String)
  end

  extend self
end
