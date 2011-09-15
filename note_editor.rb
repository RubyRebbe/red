require 'tk'
require 'editorServices.rb'

class NoteEditor < TkFrame
  def initialize( parent, item)
    super( parent)
    @parent = parent   # typically the UONEditor is the parent
    @item = item      # the UONItem that the note editor is associated with
    theNoteEditor = self

    @notemenu = TkMenu.new( self) {
      tearoff false
      
      self.add( 'command', 'label' => "commit", :background => 'green',
			'command' => proc {
        item.setNoteText theNoteEditor.getNote().get( "0.0", "end").chomp
        theNoteEditor.destroy
			})

       self.add( 'command', 'label' => "resize", :background => 'cyan',
			'command' => proc {
        puts "resize the note editor"
			})

      self.add( 'command', 'label' => "cancel", :background => 'red',
			'command' => proc {
        theNoteEditor.destroy
			})
    }

    thenotemenu = @notemenu
    editor = parent
    @note = TkText.new(self) do
      insert "end", item.getNoteText # initialize text of the note from the item

      borderwidth 1
      background "khaki"
      place :relwidth => 1.0, :relheight => 1.0
      focus

      bind "ButtonPress-3", proc { |event|
          thenotemenu.popup( 
            event.x + editor.winfo_x + theNoteEditor.winfo_x,
            event.y + editor.winfo_y + theNoteEditor.winfo_y
          )
      }
    end # note TkText

    relief "raised"
    borderwidth 3
    
    place :x => item.coords[0], :y => item.coords[1], :height => 150, :width => 250
  end # method initialize

  def getNote
    @note
  end
end
