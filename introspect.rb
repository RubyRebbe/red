#!/usr/bin/ruby

class IntrospectionPlayPen
	def initialize
		@fileContent
		puts "BEGIN introspection playpen"
	end

	def cleanup
		puts "END introspection playpen"
	end

	def to_string( filename)
		f = File.new( filename, "r")
		fileContent = f.read(nil)
		f.close
		fileContent
	end

	# sclass - stringified version of a class
	# associator - something like:  belongs_to, has_many
	# target - target of the association, e.g. ":post"
	# returns modified class as string
	def add_association( sclass, associator, target)
		# find the 'end' of the sclass definition
		# substitute for it "\tassociator target \nend"
		rsclass = sclass.chomp
		l = rsclass.length
 		rsclass[0..(l-4)] + "\n\t" + associator + " " + target + "\nend"
	end

	def to_file( filename, sclass)
		f = File.new( filename, "w")
		f.write sclass
		f.close
	end
end # class IntrospectionPlayPen

playpen = IntrospectionPlayPen.new
filename = "comment.rb"
s = playpen.to_string filename
puts "Contents of file #{filename}:"
puts s
puts "----Add association"
sclass = playpen.add_association( s, "belongs_to", ":post")
puts sclass
puts "---- Write out the modified class back to its file"
playpen.to_file( filename, sclass)
playpen.cleanup

