require 'tk'
require 'editorServices.rb'
require 'objectBindings.rb'
# require 'perp.rb'
require 'fill_color_module.rb'

class UONActor
	include UONItemIncludes

	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
		puts "ENTER UONActor.initialize()"
		super( tkCanvas, x0, y0, x1, y1, uonEditor)
		puts "just invoked superclass initializer - UONContainer"
		filling "khaki"
		puts "UONActor.initialize():  about to invoke initText ... and shouldn't"
		#initText uonEditor
		puts "UONActor.initialize:  about to create actor pieces ..."
		@actorpieces = self.createpieces
		puts "UONActor.initialize:  number of actor pieces: #{@actorpieces.length}"
		geometry( [x0, y0, x1, y1])
		puts "LEAVE UONActor.initialize()"
	end # method initialize

	def createpieces
		puts "ENTER UONActor.createpieces"
		actorpieces = []
		actorpieces << TkCanvas::TkcOval.new( tkCanvas, 0, 0, 0, 0)
		actorpieces = actorpieces + [ 1, 2, 3, 4].map { |v| 
			TkCanvas::TkcLine.new( tkCanvas, 0, 0, 0, 0)
		}
		actorpieces.each { |i| self.add i } # add actor piece i to the UONContainer
		puts "UONActor.createpieces:  number of pieces:  #{actorpieces.length}"
		actorpieces
	end

	def geometry( b)
		coords = b # I hope this works, if not, we'll do it the hard way

		@w, @h = coords[2] - coords[0], coords[3] - coords[1]
		@radius = @h/6  # radius of the head
		@torsolength = @h/3	 # length of the torso
		@darm = @h/2	# y-displacement of arms from top of bbox

		x0, y0, x1, y1 = coords # magic!
		mx = (x0 + x1)/2
		head = [ mx - @radius, y0, mx + @radius, y0 + 2*@radius]
		arms = [ x0, y0 + @darm, x1, y0 + @darm]
		torso = [ mx, y0 + 2*@radius, mx, y0 + 2*@radius + @torsolength]
		lleg = [ mx, y0 + 2*@radius + @torsolength, x0, y1]
		rleg = [ mx, y0 + 2*@radius + @torsolength, x1, y1]

		puts "UONActor.geometry():  about to set geometry of actor pieces, number is #{@actorpieces.length}"
		i = 0
		@actorpieces.each { |piece| 
			piece.coords = [ head, arms, torso, lleg, rleg][i]
			i = i + 1
		}
	end
end # class UONActor

