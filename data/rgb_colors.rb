#!/usr/bin/env ruby

# color lists extracted from
# http://people.csail.mit.edu/jaffer/Color/Dictionaries
require 'simplecolor'

# To parse X11's rgb.txt:
# c=Pathname.new("rgb.txt")
# h={}; c.each_line do |l| next if l =~ /^!/; r,g,b,name=l.strip.split(/\s+/,4); h[name.chomp]=SimpleColor::RGB.new([r.to_i,g.to_i,b.to_i]).to_hex end

def read_file(filename)
	File.open(filename, "r") do |file|
		if filename.end_with?('.gz')
			serialized_data = Zlib::GzipReader.new(file).read
		else
			serialized_data = file.read
		end
		return JSON.parse(serialized_data)
	end
end

def write_file(h, filename)
	r=nil
	File.open(filename, "w") do |file|
		file=Zlib::GzipWriter.new(file) if filename.end_with?('.gz')
		r=file.write(h.to_json)
		file.close
	end
	return r
end

def load_colors
	@x11=read_file("x11_colors.json")
	@xkcd=read_file("xkcd_colors.json")
	@resene=read_file("Resene2010_colors.json")
	@nbs=read_file("NBS-ISCC_colors.json")

	@keys=->(h) {h.keys.map {|i| SimpleColor::RGB.rgb_clean(i)}}
end

def merge_colors
	h={}
	%i(nbs resene x11 xkcd).each do |i|
		h[i]={}
		col=instance_variable_get(:"@#{i}")
		col.each do |k,v|
			h[i][SimpleColor::RGB.rgb_clean(k)]=v
		end
	end
	h
end

def write_colors
	load_colors
	h=merge_colors
	r=write_file(h, "rgb_colors.json.gz")
	puts "Wrote rgb_colors.json.gz: #{r}"
end

# (@keys[@x11] & @keys[@xkcd]).length #=>89
# (@keys[@x11] & @keys[@resene]).length #=>16
# (@keys[@x11] & @keys[@nbs]).length #=>15
# (@keys[@xkcd] & @keys[@resene]).length #=>93
# (@keys[@xkcd] & @keys[@nbs]).length #=>67
# (@keys[@resene] & @keys[@nbs]).length #=>0

if __FILE__ == $0
	Dir.chdir(File.dirname(__FILE__)) do
		puts write_colors
	end
end
