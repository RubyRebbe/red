#!/usr/bin/ruby

class BatchFileditor
	attr_accessor :filename, :contents

	def initialize(filename)
		@filename = filename

		f = File.new( @filename, "r")
			@contents = f.read(nil)
		f.close
	end # method initialize

	# appends to @contents
	def add( s)
		f = File.new( @filename, "w")
			f.write( @contents + "\n" + s)
		f.close
	end
end # class BatchFileditor

def runed
	if ARGV.length != 0 then
		bfed = BatchFileditor.new ARGV[0]
		puts "BatchFileditor on file:  #{bfed.filename}"

		if ARGV.length >= 2 then
			bfed.add ARGV[1]
		end
	else
		puts "BatchFileditor:  no filename argument"
	end
end # def runed

runed

