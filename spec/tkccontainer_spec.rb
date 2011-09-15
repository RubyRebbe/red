require 'tk'
require 'tkccontainer.rb'

class RspecWindow < TkRoot
	def initialize( keys=nil)
		super(keys)
		configure( 'geometry' => "700x400+200+200")
		title "rspec specification of TkcContainer"
		@modelCanvas = TkCanvas.new( self) {
			place('height' => 170, 'width' => 100, 'x' => 10, 'y' => 10)
		}

		x0, y0, x1, y1 = 50, 50, 100, 100
		arect = TkCanvas::TkcRectangle.new(self.canvas, x0, y0, x1, y1) { fill "blue" }
		Tk.mainloop
	end

	def canvas
		@modelCanvas		
	end
end # class RspecWindow

describe TkcContainer, " is a container of TkcItems and is a kind of TkcItem" do
	before( :each) do
		@rswindow = RspecWindow.new

		puts "about to create a Rectangle"
		x0, y0, x1, y1 = 50, 50, 100, 100
		puts "canvas:  #{@rswindow.canvas}"
		@rect2 = TkCanvas::TkcRectangle.new(@rswindow.canvas, x0 + 20, y0, x1, y1) { fill "red" }
		puts "just finished creating a Rectangle"
		#@tkcContainer = TkcContainer.new( @rswindow.canvas, x0, y0, x1, y1, nil)  { # last arg uonEditor
			#fill "red"
		#}
	end

	it " is a blank test guaranteed to succeed" do

	end

	#it "inherits from TkCanvas::TkcRectangle" do
		#@tkcContainer.class.superclass == TkCanvas::TkcRectangle
	#end

	#it "is initially empty" do
		
	#end
end
