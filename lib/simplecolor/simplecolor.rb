module SimpleColor
  class << self; attr_accessor :enabled; end
  self.enabled=true

  def colorattributes(*args)
    if SimpleColor.enabled
      result=args.map {|col| "\e[#{COLORS[col]}m" }.inject(:+)
      if SimpleColor.enabled == :shell
        return "%{"+result+"%}"
      else
        return result
      end
    else
      return ''
    end
  end

  #Usage:
  #class Foo
  #  include SimpleColor::Mixin
  #  def to_str
  #    ...
  #  end
  #end
  #foo=Foo.new()
  #foo.color(:red)
  module Mixin
    # Returns an uncolored version of the string, that is all
    # ANSI-sequences are stripped from the string.
    def uncolored(string = nil) # :yields:
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

    #wrap self or the first argument with colors
    #Examples:
    #    SimpleColor.color("blue", :blue, :bold)
    #    SimpleColor.color(:blue,:bold) { "blue" }
    #    SimpleColor.color(:blue,:bold) << "blue" << c.color(:clear)
    #pareil pour uncolored
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
        matched = arg.match(/^(\e\[([\d;]+)m)*/)
        arg.insert(matched.end(0), SimpleColor.colorattributes(*args))
        arg.concat(SimpleColor.colorattributes(:clear)) unless arg =~ /\e\[0m$/
        return arg
      end
    end
  end

  #after SimpleColor.mix_in_string, one can do
  #"blue".color(:blue,:bold)
  include SimpleColor::Mixin
  def mix_in_string
    String.class_eval {include SimpleColor::Mixin}
  end

  extend self
end
