require 'tk'
require 'editorServices.rb'
require 'objectBindings.rb'
require 'perp.rb'
require 'fill_color_module.rb'

class TkcText
	def destruct
		self.destroy
	end
end

# by tagging the text item with it's UONItem tag, we should simplify code massively ...
# I cannot figure out have to get the text string out of a TkcText object, so I work around
module TextServices # mixin for uonItems managing a piece of text
	def createTextItem( editor)
		# puts "ENTER module TextServices.createTextItem. editor = #{editor}"
		@textItem = TkCanvas::TkcText.new( editor.getModelCanvas, 0, 0)
		# puts "@textItem: #{@textItem}"
		@textItem.tag = self.gettag
		# puts "LEAVE createTextItem():  UONItem #{self} with textItem with tag #{@textItem.gettags}"
	end

	def initText( editor)
		createTextItem( editor)
		# setText self.class.name
		updateTextLocation
	end

	def updateTextLocation
		c = self.getCenter
		dx, dy = c[0] - @textItem.coords[0], c[1] - @textItem.coords[1]
		@textItem.move( dx, dy)
	end

	def getText  # returns string with content of textItem
		@textItem.cget( "text")
	end

  def getTextItem
    @textItem
  end

	def setText( t) # t is String used to set contents of textItem
		@textItem.text t
	end

	def destroyText
    # puts "entering TextServices.destroyText ... #{@textItem}"
    #@textItem.destruct
		@textItem.destroy
	end
end  # module TextServices

module Initialization
  def init( canvas, x0, y0, x1, y1, editor, color)
		@tag = TkcTag.new( canvas)
		self.tag = @tag
		initText editor
		initializeBindings(canvas, x0, y0, x1, y1, editor)
		geometry( [ x0, y0, x1, y1])
    filling( color)
  end # method init

	def gettag # primary tag for the object
		@tag
	end

	# 21 june 2011: design thought:  separate UONItem creation (initialize()) from setting of geometry
	# useful for complex items like:  UONActor, UONCondition, UONPrimitive
	# useful for re-sizing, as moving is handled by tagging
	# arg: b - bounding box [ x0, y0, x1, y1]
	def geometry( b)
		# over-ride where neeeded, e.g. UONActor
	end # method geometry

  def filling( color)
    fill( color); self.setfillcolor fill
  end # method filling

  def to_serialize # to_passivate:  common (base) method.  can be over-ridden
    s = "#{self.class}.new( editor.getModelCanvas, "
    self.bbox.each { |coord| s = s + "#{coord}, " }
    s = s + "editor) "
    s = s + "{ setText '#{self.getText}'; fill '#{self.fill}' }"
    s
  end
end # module Initialization

module UONItemIncludes
	include EditorServices
	include ObjectBindings
	include TextServices
  include FillColorModule
  include Initialization
end # module UONItemIncludes

# The base type UONItem is mixed in from the module ObjectBindings
class UONObject < TkCanvas::TkcOval
	include UONItemIncludes
	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
    super( tkCanvas, x0, y0, x1, y1, :width => '2')
    init( tkCanvas, x0, y0, x1, y1, uonEditor, "green")
	end # method initialize
end # class UONObject

class UONAction < TkCanvas::TkcRectangle
	include UONItemIncludes
	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
		super( tkCanvas, x0, y0, x1, y1)
    init( tkCanvas, x0, y0, x1, y1, uonEditor, "pink")
	end # method initialize
end # class UONAction

class UONCondition < TkCanvas::TkcPolygon
	include UONItemIncludes
	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
		super( tkCanvas, self.getVertices(x0, y0, x1, y1), :outline => 'black')
    init( tkCanvas, x0, y0, x1, y1, uonEditor, "orange")
	end # method initialize

	# establish geometry of UONCondition as a function of bounding box
	def getVertices( x0, y0, x1, y1) # arguments define bounding box
		w, h = x1 - x0, y1 - y0
		hh = (h/2).to_i

		[
			[ hh, 0], [ w - hh, 0], [ w, hh], [ w - hh, h], [ hh, h], [ 0, hh]
		].map do |v| [ v[0] + x0, v[1] + y0 ] end.flatten
	end # method getVertices
end # class UONCondition

class UONPrimitive < TkCanvas::TkcPolygon
	include UONItemIncludes
	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
		super( tkCanvas, self.getVertices(x0, y0, x1, y1), :outline => 'black')
    init( tkCanvas, x0, y0, x1, y1, uonEditor, "light green")
    bind( "Double-1") {} # turn off text editing, requires setting primitive type via menu
    # we may want to revisit this GUI requirement
	end # method initialize

	# establish geometry of UONCondition as a function of bounding box
	def getVertices( x0, y0, x1, y1) # arguments define bounding box
		w, h = x1 - x0, y1 - y0
		d = 5 # size of corner chip

		[
			[ d, 0], [ w - d, 0],
      [ w, d], [w, h - d],
      [ w - d, h], [ d, h],
      [ 0, h - d], [ 0, d]
		].map do |v| [ v[0] + x0, v[1] + y0 ] end.flatten
	end # method getVertices
end # class UONPrimitive

class UONComment < TkCanvas::TkcRectangle
	include UONItemIncludes
	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
		super( tkCanvas, x0, y0, x1, y1)
    init( tkCanvas, x0, y0, x1, y1, uonEditor, "yellow")
	end # method initialize
end # class UONAction

# 18 mar 2010:  beginnings of requirements acquisition support
class UONCard < TkCanvas::TkcRectangle
	include UONItemIncludes
	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
		super( tkCanvas, x0, y0, x1, y1)
    init( tkCanvas, x0, y0, x1, y1, uonEditor, "khaki")
    @noteText = ""
	end # method initialize

  def getNoteText
    @noteText
  end

  def setNoteText( t)
    @noteText = t
  end

 def to_serialize
    s = "#{self.class}.new( editor.getModelCanvas, "
    self.bbox.each { |coord| s = s + "#{coord}, " }
    s = s + "editor) "
    s = s + "{ setText '#{self.getText}'; fill '#{self.fill}' ; setNoteText '#{self.getNoteText}' }"
    s
  end
end # class UONAction

# need to include TextServices and subclass from something like the empty item!
class UONText < TkCanvas::TkcRectangle  #TkcText
	include UONItemIncludes
	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
		super( tkCanvas, x0, y0, x1, y1)
    init( tkCanvas, x0, y0, x1, y1, uonEditor, "lightgray")
	end # method initialize
end # class UONText

class UONConnection < TkCanvas::TkcLine
	include UONItemIncludes
	attr_accessor :srcItem, :destItem

	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor, src, dest)
		super( tkCanvas, x0, y0, x1, y1, :width => 2, :arrow => 'last')
    init( tkCanvas, x0, y0, x1, y1, uonEditor, "black")
    
    self.srcItem = src; self.destItem = dest
		lower
		addtag srcItem.gettag; addtag destItem.gettag
		# connection's text needs all three tags to get properly destroyed
		self.getTextItem.addtag srcItem.gettag; self.getTextItem.addtag destItem.gettag
		
    @src = ConnectionTerminus.new srcItem, destItem, uonEditor
    @dest = ConnectionTerminus.new destItem, srcItem, uonEditor
	end # method initialize

  # returns source or destination item whose class == klass or nil
  # if source and destination are of same class, it prefers srcItem
  def getItem( klass)
    retItem = nil
    if srcItem.class == klass then
      retItem = srcItem
    elsif destItem.class == klass then
      retItem = destItem
    end
    retItem
  end

	# ensure that the coords of the connection match the centers of its src and dest items
	def updateCoords
		sc, dc = srcItem.getCenter, destItem.getCenter
		self.coords( sc[0], sc[1], dc[0], dc[1])
    # handle @src and @dest
    @src.update
    @dest.update

		updateTextLocation
	end # method updateCoords

  def toggleSource
    @src.toggle
    setStatus "#{self} toggleSource: #{@srcDot}"
  end

  def toggleDestination
    @dest.toggle
    setStatus "#{self} toggleDestination"
  end

  def destroyTermini
    # puts "Entering UONConnection.destroyTermini: @src = #{@src}, @dest = #{@dest}"
    if @src != nil then @src.destroy; @src = nil end
    if @dest != nil then @dest.destroy; @dest = nil end
  end

  def destruct
    # puts "Entering UONConnection.destruct on item #{self} ..."
    self.destroyTermini

    self.destroyText

    # puts "about to invoke the super.destruct"
    # ObjectBindings.destruct
    self.destroy
  end
end # class UONConnection

class UONAssociator < TkCanvas::TkcOval
	include UONItemIncludes

  attr_accessor :srcConnector, :destConnector
  # attr_accessor :srcConnector_id, :destConnector_id  # for passivation and activation

	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
		super( tkCanvas, x0, y0, x1, y1, :outline => 'black', :width => '2')
    init( tkCanvas, x0, y0, x1, y1, uonEditor, "white")
	end # method initialize

	def updateCoords

	end # method updateCoords

	attr_accessor :owner # owner of the terminus
end # class UONAssociator

# implements recursive container pattern via canvas tags
class UONContainer < TkCanvas::TkcRectangle
	include UONItemIncludes

	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
    super( tkCanvas, x0, y0, x1, y1, :width => '1')
    init( tkCanvas, x0, y0, x1, y1, uonEditor, "")
	end # method initialize
	
	# add UONItem into container
	def add( item)
		item.addtag self.gettag
	end

	# remove UONItem from container
	def remove( item)
		item.dtag( self.gettag)
	end
end # class UONContainer

# we use this object for both resizing and grouping. is that a bad idea?
class UONGroupingBox < UONContainer
  include UONItemIncludes

	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
    # assert: pre-condition:  at least 1 UONItem in bbox( x0, y0, x1, y1)
		super( tkCanvas, x0, y0, x1, y1, uonEditor)
		outline "blue"
		@editor = uonEditor
		initText uonEditor
		initializeBindings(tkCanvas, x0, y0, x1, y1, uonEditor)
	end

  # pre-condition:  list.size > 0
  # work to be done:  turn off event handling for contained objects
  # turn on event handling for self, particularly motion
  def setList( list)
    @groupList = list
    # calculate minimum bbox to contain the list
    b = @groupList[0].bbox
    @groupList.each { |i| b = self.unite( b, i.bbox) }

    # turn off item bindings for items in group
    bindings = self.getBindings
    @groupList.each { |i|
      bindings.each { |p| i.bind p[0], proc { |event| } } # the null proc ...
    }

		# add the UONGroupingBox tag to each of the contained items
		c = editor.getModelCanvas
		c.addtag_enclosed( self.gettag, b[0], b[1], b[2], b[3])

    # establish bbox of group
    self.coords( b[0], b[1], b[2], b[3])
    outline "purple"
		puts "LEAVE setList of #{self}"
  end
  
  #over-rides translate in module ObjectBindings
  def translate( dx, dy)
    self.move(dx, dy)
    @groupList.each { |i| i.translate( dx, dy) }
  end

  def getList
   @groupList
  end

  # returns smallest rectangle bounding box1 and box2
  def unite( box1, box2)
    # calculate the lower of tolowerupper( box1.lower, box2.lower)
    l = (self.tolowerupper( box1[0..1], box2[0..1]))[0]
    # calculate the upper of tolowerupper( box1.upper, box2.upper)
    u = (self.tolowerupper( box1[2..3], box2[2..3]))[1]
    [l, u].flatten
  end

  # signature:  ( p, q) -> (l, u)
  # p, q are two points in the plane.
  # they define a rectangle (bbox) whose sides are parallel to the coordinate axes
  # l, u are respectively the north-west and south-east corners of the rectangle
  def tolowerupper( p, q)
    d = [q[0] - p[0], q[1] - p[1]]
    # four cases:
    if d[0] >= 0 && d[1] >= 0 then
      l, u = p, q
    elsif d[0] < 0 && d[1] < 0 then
      l, u = q, p
    elsif d[0] >= 0 && d[1] <= 0 then
     l = [ p[0], p[1] + d[1]]
     u = [ p[0] + d[0], p[1]]
    elsif d[0] <= 0 && d[1] >= 0 then
     l = [ p[0] + d[0], p[1]]
     u = [ p[0], p[1] + d[1]]
    end
    [ l, u]
  end

  def destruct
    #puts "Entering UONGroupingBox.destruct on item #{self} ..."
    self.getList.each { |item| item.destruct }
    self.destroy
    #ObjectBindings.destruct
  end

	attr_reader :editor
end # class UONGroupingBox

# poor man's arrow head on a connection
class UONDot < TkCanvas::TkcOval
	include UONItemIncludes
	def initialize( tkCanvas, x0, y0, x1, y1, uonEditor)
		super( tkCanvas, x0, y0, x1, y1)
		fill( "blue"); self.setfillcolor fill
		initText uonEditor
		initializeBindings(tkCanvas, x0, y0, x1, y1, uonEditor) # from module ObjectBindings
    bind( "Motion") do |event| end # turn off binding to mouse motion/dragging
	end # method initialize
end # class UONDot

# a UONConnection has two termini
class ConnectionTerminus
  def initialize( it, faritem, ed)
    @dot = nil
    @intersector = IntersectUONItem.new( it)
    @farItem = faritem
    @editor = ed
  end

  def getItem
    @intersector.getItem
  end

  def getDot
    @dot
  end

  # toggles the dot on or off
  def toggle
    if @dot == nil then
      radius = 5
      pt = @intersector.getIntersection( @farItem.getCenter)
      @dot = UONDot.new( @editor.getModelCanvas,
        pt[0], pt[1], pt[0] + radius, pt[1] + radius, @editor)
      @dot.setCenter pt
    else
      @dot.destroy; @dot = nil
    end # @dot is nil?
  end # method toggle

  def destroy
    if @dot != nil then
      @dot.destroy; @dot = nil
    end
  end

  def destruct
    puts "Entering ConnectionTerminus.destruct on item #{self} ..."
    if @dot != nil then
      @dot.destroy; @dot = nil
    end
  end

  def update
    # update the dot position if toggled on
    if @dot != nil then
      @dot.setCenter @intersector.getIntersection( @farItem.getCenter)
    end
  end
end # class ConnectionTerminus

