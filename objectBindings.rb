require 'tk'
require 'editorServices.rb'
# require 'perp.rb'

# used as mix-in for UONItems
# uses module EditorServices
module ObjectBindings
	def initializeBindings( tkCanvas, x0, y0, x1, y1, uonEditor)
		self.editor = uonEditor # from module EditorServices ...

		# mechanism for select-moveitem-unselect scenario
		@selected = false
		@dX = 0; @dY = 0 # delta from ButtonPress to upper left corner of item

    @itemBindings = [
      [ "Double-1",
        proc { |event|
          i = self
          self.setStatus "edit text on item #{self} at #{event.x}, #{event.y}"

          # item text editor
          TkEntry.new( self) do
            font( "family" => "helvetica", "size" => 10, "weight" => "bold")
            insert( "end", i.getText)
            # establish dimensions and move itemTextEditor over item to event location
            place( :height => 25, :width => 150, :x => event.x, :y => event.y)
            focus
            # bind to key event ...
            bind( "KeyPress") do |event|
              if event.keysym == "Return" then
              # assert winfo_parent == uonEditor
                if i then # set string in UONItem to content of text widget
                  i.setText self.get.chomp
                  self.destroy # expect this to destroy the item text editor ...
                end
              end
            end # bind KeyPress
          end  # itemTextEditor
        }
      ],
      [
        "ButtonPress-3",
        proc { |event|
          # needed to prevent editor popup on item and initialize resize scenario
          setEventItem( self)
          self.setStatus("Item menu trigger at #{event.x}, #{event.y}")
          # need coord transformation: add in upper left coords of uonEditor
          editor.getItemMenu(self).popup( event.x + editor.winfo_x, event.y + editor.winfo_y)
        }
      ],
      [ "ButtonPress-1",
        proc { |event|
          setEventItem self
          self.setStatus( "ButtonPress on object #{self} at #{event.x}, #{event.y}")
          @selected = true
          # calculate delta from event point to upper left corner
          @dX = event.x - self.bbox[0]; @dY = event.y - self.bbox[1]
        }
      ],
      [ "Motion",
        proc { |event|
          if @selected then
            self.setStatus "Motion event on object #{self} at #{event.x}, #{event.y}"
            dx = event.x - self.bbox[0] - @dX
            dy = event.y - self.bbox[1] - @dY
						self.gettag.move( dx, dy) # elegant
            # move the associated connections ... what if we tagged the item's connections?
            getConnections.each do |c| c.updateCoords end
          end
        }
      ],
      [ "ButtonRelease",
        proc { |event|
          if @selected  then # move/drag item scenario
            self.setStatus("ButtonRelease event on object #{self} at #{event.x}, #{event.y}")
            @selected, @dX, @dY = false, 0, 0
          end
        }
      ],
      [ "Enter",
        proc { |event| 
          editor.getModelCanvas.destItem = self
          self.setStatus "Entered UONItem #{self}"
          # no guarantee that item id survives passivation and activation
          # puts "event: enter item.  item id = #{self.id}"
        }
      ],
      [ "Leave",
        proc { |event| 
          # editor.getModelCanvas.destItem = self
          self.setStatus "Leave UONItem #{self}"
        }
      ]
    ] #@itemBindings

    @itemBindings.each { |p| bind p[0], p[1] }
	end # method initialize

  def getBindings
    @itemBindings
  end

  # moves UONItem by the delta (dx, dy)
  # provides opportunity for over-ride in inheriting classes
  def translate( dx ,dy)
    self.move( dx, dy)
  end

  # over-rideable explicit destructor in uonobjects
  def destruct
    #puts "Entering module ObjectBindings.destruct on item #{self} ..."
    #puts "about to destruct connections  ..."
    self.getConnections.each do |c| c.destruct end
    #puts "about to destroyText ..."
    self.destroyText
    #puts "about to destroy self:  #{self}"
    self.destroy
  end

	# given a bounding box, returns coordinates of center as tuple
	# pre-condition:  self is an UONItem
	def getCenter
		box = self.bbox
		[ (box[0] + box[2])/2, (box[1] + box[3])/2 ]
	end # method getCenter

  # make the point c the center of the item
  def setCenter( c)
    w2, h2 = width/2, height/2
    x0, y0 = c[0] - w2, c[1] - h2
    x1, y1 = x0 + width, y0 + height
    self.coords( x0, y0, x1, y1)
  end

	# return list of all connections associated with this uonItem
	def getConnections
		r = []
		editor.getModelCanvas.getItems(UONConnection).each do |c|
			if (c.srcItem == self) || (c.destItem == self) then r.push c end
		end
		r
	end

	# coords 0, 1, 2, 3
	#        x0 y0 x1 y1
	def width # width of bboxpoint
		self.coords[2] - self.coords[0]
	end

	def height # height of bbox
		self.coords[3] - self.coords[1]
	end
end # module ObjectBindings
