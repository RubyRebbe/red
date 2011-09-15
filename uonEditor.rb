#!/usr/bin/ruby
# for now set shell variable RUBYLIB="."; export RUBYLIB

require 'tk'
require 'modelcanvas.rb'
require 'uonObject.rb'
require 'uonMenu.rb'
require 'redusecases.rb'
require 'ucasefactory.rb'

class UONEditor < TkRoot
  attr_accessor :model_filename

	def getEditor
		return self
	end  # method getEditor

	def getStatus
		return @statusText
	end # method getStatus

	def getMenu
		@editorMenu
	end # method getMenu

  # gets a popup item menu as a function of the item type
  # candidate for dynamic binding as uonItem method
	def getItemMenu( item)
    h = { 
      UONConnection => @connectionItemMenu, 
			UONCard => @cardItemMenu,
      UONPrimitive => @primitiveItemMenu
    }
    menu = @itemMenu # default return value
    if h.key?( item.class) then
      menu = h[item.class]
    end
    menu # return value
	end

	def getModelCanvas
		@modelCanvas
	end

  def getEdTitle
    @edTitle
  end

	def initialize( keys=nil)
		super( keys)
    @edTitle ="Ruby on Rails UONEditor"
		title @edTitle
    @model_filename = ""

		minsize( 400, 300)
		# move upper left corner of top window to ...
		configure( 'geometry' => "700x400+200+200")
		
		@statusText = TkText.new( self) do
			height 1  # 1 text editor line high
			font( "family" => "helvetica", "size" => 10, "weight" => "bold")
			insert( "end", "Welcome to Tsvi's UONEditor in Ruby Tk!")
			pack( "side" => "bottom", "fill" => "x")
    end
		@modelCanvas = ModelCanvas.new( self)
		@editorMenu = EditorMenu.new( self)
		@itemMenu = ItemMenu.new( self)

    @connectionItemMenu = SelectionMenu.new( self, 'role arity',
      [ "belongs_to", "has_one", "has_many" ]
    )
    # @connectionItemMenu = ConnectionMenu.new( self)
    
    @cardItemMenu = ItemMenu.new( self) {
      add( 'command', 'label' => "note",
			  'command' => proc {
          i = editor.getCurrentItem
				  if i.class == UONCard then
            editor.setStatus "edit note"
            note_editor = NoteEditor.new editor, i
          end # if
			  }
		  )
    }

    @primitiveItemMenu = SelectionMenu.new( self, 'primitive types',
      [ 
        "primary_key", "string", "text", "integer", "float", "decimal", "datetime", 
        "timestamp", "time", "date", "binary", "boolean", "references"
      ]
    )

    # create an associator menu sub-typed off of uonItem menu
    # factor out of primitiveItemMenu the list of labels that restrict the setting of the text
    # of the item

    	@scrollbar = TkScrollbar.new(root).pack('side'=>'right', 'fill'=>'y')

    	@modelCanvas.configure( :scrollregion => '0 0 700 2000')
    	@scrollbar.command( proc { |args|
        	@modelCanvas.yview(*args)
    	})
    	@modelCanvas.yscrollcommand( proc { |first, last|
        	@scrollbar.set( first, last)
    	})

    @editorState = UCBase.new( self) # use case hook. initial state is base class instance

    # fire up event processing
    Tk.mainloop
	end #method initialize

  def getState
    @editorState
  end

  def setState( state)
    @editorState = state
  end

  def getCurrentItem
    c = self.getModelCanvas.find_withtag "current"
    return (c.length == 0) ? nil : c[0]
  end

  def setStatus( statusString)
		@modelCanvas.setStatus statusString
	end # method setStatus - delegates to canvas

	def setTextFocus
		@statusText.clear
		@statusText.focus
	end
end # class UONEditor

UONEditor.new()
