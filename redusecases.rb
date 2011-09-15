
class UCBase
	def initialize( uonEditor)
		@editor = uonEditor
	end

	def getEditor
		@editor
	end

	def mouseEnter( event)
		return self
	end # method Enter 

	def mouseButtonRelease( event)
		return self
	end # method ButtonRelease 

	def mouseMotion( event)
		return self
	end # method Motion 

	def mouseButton1( event)
		return self
	end # method Button1 

	def mouseButton3( event)
		return self
	end # method Button3 

	def mouseDoubleButton1( event)
		return self
	end # method DoubleButton1 

	def canvasButtonRelease( event)
		return self
	end # method ButtonRelease

	def canvasMotion( event)
    self.getEditor.setStatus( "UCBase.Canvas Motion:  ( #{event.x}, #{event.y})")
		return self
	end # method Motion

	def canvasButton1( event)
    ed = self.getEditor
    # Disambiguate item vs. canvas click here
    return (ed.getCurrentItem == nil) ? UCGroupItems.new( ed, event) : self
	end # method Button1

	def canvasButton3( event)
    ed = self.getEditor
    # disambiguate item vs. canvas click
    if ed.getCurrentItem == nil then
      ed.setStatus "Editor Popup menu trigger at #{event.x}, #{event.y}"
      ed.getMenu.popup( event.x + ed.winfo_x, event.y + ed.winfo_y)
    end
		return self
	end # method Button3
end # class UCBase

class UCGroupItems < UCBase
  def initialize( uonEditor, event)
		super( uonEditor)
    ed = self.getEditor
    ed.setStatus( "Begin grouping at #{event.x}, #{event.y}")
		@groupingBox = UONGroupingBox.new( ed.getModelCanvas, event.x, event.y,
      event.x, event.y, ed)
		puts "UCGroupItems.initialize(): finished creating UONGroupingBox"
	end

	def mouseEnter( event)
		return self
	end # method Enter

	def mouseButtonRelease( event)
		return self
	end # method ButtonRelease

	def mouseMotion( event)
		return self
	end # method Motion

	def mouseButton1( event)
		return self
	end # method Button1

	def mouseButton3( event)
		return self
	end # method Button3

	def mouseDoubleButton1( event)
		return self
	end # method DoubleButton1

	def canvasButtonRelease( event)
    # capture the list of enclosed canvas items
    bx = @groupingBox.bbox
    grouplist = getEditor.getModelCanvas.find_enclosed( bx[0], bx[1], bx[2], bx[3])
    # assert: grouplist contains @groupingBox, and don't want it!
    grouplist.delete @groupingBox
    
    if grouplist.size > 0 then
      putsGroup grouplist
      @groupingBox.setList grouplist
    else
      @groupingBox.destroy
    end

		return UCBase.new( self.getEditor)
	end # method ButtonRelease

  def putsGroup( list)
    puts "BEGIN group list, size: " + list.size.to_s
    list.each { |item|
      puts "\t" + item.class.name
    }
    puts "END group list"
  end

	def canvasMotion( event)
    x0, y0 = @groupingBox.coords[0], @groupingBox.coords[1]
		@groupingBox.coords( x0, y0, event.x, event.y)
    getEditor.setStatus "UCGroupItems.canvasMotion:  ( #{event.x}, #{event.y})"
		return self
	end # method Motion

	def canvasButton1( event)
		return self
	end # method Button1

	def canvasButton3( event)
		return self
	end # method Button3

end # class UCGroupItems

class UCResizeItem < UCBase
  def initialize( uonEditor)
		super( uonEditor)
    ed = self.getEditor
    @item = ed.getCurrentItem
    @resizeBox = UONGroupingBox.new( ed.getModelCanvas,
      @item.coords[0], @item.coords[1],
			@item.coords[2], @item.coords[3], ed)
    ed.setStatus( "Begin resize of item #{@item}")
	end

	def mouseEnter( event)
		return self
	end # method Enter

	def mouseButtonRelease( event)
		return self
	end # method ButtonRelease

	def mouseMotion( event)
		return self
	end # method Motion

	def mouseButton1( event)
		return self
	end # method Button1

	def mouseButton3( event)
		return self
	end # method Button3

	def mouseDoubleButton1( event)
		return self
	end # method DoubleButton1

	def canvasButtonRelease( event)
    @item.coords(
					@resizeBox.coords[0],@resizeBox.coords[1],
					@resizeBox.coords[2],@resizeBox.coords[3]
				)
		
		@item.geometry @resizeBox.coords # this is what we are testing right now

		# following is not object oriented, should over-ride an update method in base class
		if (@item.class == UONCondition) || (@item.class == UONPrimitive) then
      @item.coords @item.getVertices(
        @resizeBox.coords[0],@resizeBox.coords[1],
				@resizeBox.coords[2],@resizeBox.coords[3]
			)
		end
    @item.updateTextLocation
    @resizeBox.destroy
		return UCBase.new( self.getEditor)
	end # method ButtonRelease

	def canvasMotion( event)
    x0, y0 = @resizeBox.coords[0], @resizeBox.coords[1]
		@resizeBox.coords( x0, y0, event.x, event.y)
    getEditor.setStatus "UCResizeItem.canvasMotion:  ( #{event.x}, #{event.y}"
		return self
	end # method Motion

	def canvasButton1( event)
		return self
	end # method Button1

	def canvasButton3( event)
		return self
	end # method Button3

end # class UCResizeItem

class UCConnectItem < UCBase
  def initialize( uonEditor)
		super( uonEditor)
    ed = self.getEditor
    @source = ed.getCurrentItem
    @destination = nil
    c = @source.getCenter
    # don't know what values to initialize with ...
    destX, destY = c[0], c[1]
		@connectionLine = TkCanvas::TkcLine.new( ed.getModelCanvas, c[0], c[1], destX, destY) do
			fill "blue"
			lower
		end
    ed.setStatus( "Begin connecting item #{@source} to somewhere ...")
	end
	def mouseEnter( event)
		return self
	end # method Enter

	def mouseButtonRelease( event)
		return self
	end # method ButtonRelease

	def mouseMotion( event)
		return self
	end # method Motion

	def mouseButton1( event)
		return self
	end # method Button1

	def mouseButton3( event)
		return self
	end # method Button3

	def mouseDoubleButton1( event)
		return self
	end # method DoubleButton1

	def canvasButtonRelease( event)
    ed = self.getEditor
    @destination = ed.getCurrentItem
    if (@destination != nil) && (@destination.class != TkcText) && (@destination != @connectionLine) then
      c = @destination.getCenter
      if createAssociation == nil then
			connection = UONConnection.new(ed.getModelCanvas,
        @connectionLine.coords[0],@connectionLine.coords[1],c[0],c[1], ed,
        @source, @destination)
      ed.setStatus( "Connecting #{@source} to #{@destination}")
      end
    end
    @connectionLine.destroy
		return UCBase.new( self.getEditor)
	end # method ButtonRelease

  # creates a bi-directional association (bda) between two UONObject's (business objects)
  # pre-condition:  @source != nil && @destination != nil
  def createAssociation
    bda = nil
    if (@source.class == UONObject) && (@destination.class == UONObject) then
      # need to create three items:  associator, two connections
      ed = self.getEditor
      
      # position half-way between the @source and the @destination
      srcCenter, destCenter, w = @source.getCenter, @destination.getCenter, 15
      x0, y0 = (srcCenter[0] + destCenter[0])/2, (srcCenter[1] + destCenter[1])/2

      bda = UONAssociator.new( ed.getModelCanvas, x0, y0, x0 + w, y0 + w, ed)
      # will need to passivate bda srcConnector and destConnector attributes, and fill color
      bda.srcConnector = UONConnection.new( ed.getModelCanvas, 0, 0, 0, 0, ed, @source, bda) {
        updateCoords; filling "purple"; lower
      }
      bda.destConnector = UONConnection.new( ed.getModelCanvas, 0, 0, 0, 0, ed, bda, @destination) {
        updateCoords; filling "purple"; lower
      }
    end
    bda
  end

	def canvasMotion( event)
    c = @source.getCenter
		@connectionLine.coords( c[0], c[1], event.x, event.y)
		pos = "#{event.x}, #{event.y}"
		getEditor.setStatus( "Connection scenario, Motion from Source item:  #{@source} to " + pos)
		return self
	end # method Motion

	def canvasButton1( event)
		return self
	end # method Button1

	def canvasButton3( event)
		return self
	end # method Button3
end # class UCConnectItem

class UCEditItemText < UCBase 
	def mouseEnter( event)
		return self
	end # method Enter 

	def mouseButtonRelease( event)
		return self
	end # method ButtonRelease 

	def mouseMotion( event)
		return self
	end # method Motion 

	def mouseButton1( event)
		return self
	end # method Button1 

	def mouseButton3( event)
		return self
	end # method Button3 

	def mouseDoubleButton1( event)
		return self
	end # method DoubleButton1 

	def canvasButtonRelease( event)
		return self
	end # method ButtonRelease

	def canvasMotion( event)
		return self
	end # method Motion

	def canvasButton1( event)
		return self
	end # method Button1

	def canvasButton3( event)
		return self
	end # method Button3
end # class UCEditItemText
