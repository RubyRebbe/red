require 'tk'
require 'editorServices.rb'
require 'intersection_test.rb'
require 'objectBindings.rb'
require 'note_editor.rb'
require 'rmodel.rb'

class CreateItemMenu < TkMenu
  include EditorServices
  def initialize( parentMenu, uonEditor)
    super( parentMenu)
    tearoff false
    editor = uonEditor

    [ # list of types of uon items available to be created - soon UONSubModel
			UONObject, UONAction, UONCondition, UONPrimitive, 
      UONAssociator, UONComment, UONText, UONCard, UONContainer
		].each do |c| # for each class in the list ...!
			self.add( 'command',
        'label'   => c.name[3..-1],
        'command' => proc {
          x0, y0 = parentMenu.winfo_x - editor.winfo_x, parentMenu.winfo_y - editor.winfo_y
          dim = (c == UONAssociator) ? [15, 15] : [75, 50]; w, h = dim[0], dim[1]
          i = c.new( editor.getModelCanvas, x0, y0, x0 + w, y0 + h, editor)
          # all item bindings: i.bindinfo
        }
			)
		end  # loop over classes in uonItem class list
  end # method initialize
end # class CreateItemMenu

# EditorMenu controls the editor as a whole
class EditorMenu < TkMenu
	include EditorServices
	def initialize( uonEditor)
		super( uonEditor)
		tearoff false
		# setEditor( uonEditor) # from module EditorServices
		self.editor = uonEditor
		
    self.add_cascade( :label => "create item ...", 
      :menu => CreateItemMenu.new( self, uonEditor))

		@filename = ""  # filename for save and open file dialogs
		@ftypes = [
       	 ["UON files", '*.uon'],
         ["All files",'*']
     	]

    @edTitle = editor.getEdTitle

		self.add( 'command', 'label' => "open ...", 
			'command' => proc { 
				# assert:  @filename has class string and is empty if nothing selected
				@filename = Tk.getOpenFile( :filetypes => @ftypes, :initialfile => @filename,
					:title => "open #{@filename.split("/").last}") # dialog box
				if @filename != "" then # could use some more dummy-proofing
					f = File.new( @filename, "r")
					serializedModel = f.read(nil)
					f.close
					editor.getModelCanvas.deserialize serializedModel
          editor.title @edTitle + " - #{@filename.split("/").last}"
          editor.model_filename = @filename
					setStatus "open model from file #{@filename}"
				end	
			} 
		)

		self.add( 'command', 'label' => "save ...",
			'command' => proc {
				# assert:  @filename has class string and is empty if nothing selected
				@filename = Tk.getSaveFile( :filetypes => @ftypes, :initialfile => @filename,
					:title => "save to #{@filename.split("/").last}")  # dialog box
				if @filename != "" then
					f = File.new( @filename, "w")
					f.write editor.getModelCanvas.serialize.inspect # serialize and store the model
					#f.write editor.getModelCanvas.serialize # serialize and store the model
					f.close
					setStatus "save model to file #{@filename}"
          editor.model_filename = @filename
          editor.title @edTitle + " - #{@filename.split("/").last}"
				end
			}
		)

    self.add( 'command', 'label' => "export to rails ...",
			'command' => proc {
        rmodel = RModel.new( editor.getModelCanvas.find( "all"), editor.model_filename)
        script = rmodel.to_script
				# write the script to a file
				puts "RAILS CMD file: " + rmodel.project_name + ".rails"
				f = File.new( rmodel.project_name + ".rails", "w")
					f.write script
					f.chmod 0777
				f.close

				puts script
				setStatus "export model to Ruby on Rails"
			}
		)

		self.add( 'command', 'label' => "remove all", 
			'command' => proc { 
				editor.getModelCanvas.delete :all		
				setStatus "remove all model elements from canvas"
        editor.title @edTitle
			} 
		)

    self.add( 'command', 'label' => "package/subsystem",
			'command' => proc {
        toplevelWindow = TkToplevel.new( editor) {
          title "Sub-System"
          geometry "700x400+200+200"
          configure'bg'=>"cyan"
        }
				setStatus "create sub-system"
        editor.title @edTitle
			}
		)
  
		self.add( 'command', 'label' => "quit", 
			'command' => proc { 
				puts "quitting Tsvi's uonEditor in Ruby Tk"
				editor.destroy
			} 
		)
	end # method initialize
end # class EditorMenu

class ColorMenu < TkMenu
  include EditorServices
  
  def initialize( parentMenu, uonEditor)
    super( parentMenu)
    tearoff false
    editor = uonEditor

    @colors = [
      "green", "light green", "sea green", "light sea green",
      "pink", "orange", "yellow", "khaki",
      "white", "black", "blue", "lightgray", "purple",
      "magenta"
    ]

    @colors.each { |clr|
      self.add( 'command', 'label' => clr, 'background' => clr,
			'command' => proc {
        i = editor.getCurrentItem
        i.fill clr
        editor.setStatus "new color of item #{i} is #{clr}"
			 }
		  )
    }
  end # def initialize
end # class ColorMenu

# ItemMenu controls the UONItem
# 3june09:  how to create an ItemMenu sensitive to the type of the item,
# specifically a UONConnection?  Hmmm ... possibly inheritance?
class ItemMenu < TkMenu
	include EditorServices
	def initialize( uonEditor)
		super( uonEditor)
		tearoff false
		# setEditor( uonEditor) # from module EditorServices
		self.editor = uonEditor

    self.add_cascade( :label => "color ...", :menu => ColorMenu.new( self, uonEditor))

		self.add( 'command', 'label' => "resize", 
			'command' => proc { 
        editor.setState UCResizeItem.new( editor)
			} 
		)

		self.add( 'command', 'label' => "autosize", 
			'command' => proc { 
				item, dw, dh = editor.getCurrentItem, 10, 20

 				item.coords(
					item.coords[0], 
					item.coords[1],
					item.coords[0] + item.getTextItem.font.measure( item.getText) + dw, 
					item.coords[1] + item.getTextItem.font.metrics[2][1] + dh # vertical linespace
				)

				# following is not object oriented, should over-ride an update method in base class
				if (item.class == UONCondition) || (item.class == UONPrimitive) then
      		item.coords item.getVertices(
        		item.coords[0],item.coords[1],
						item.coords[2],item.coords[3]
					)
				end
				item.updateTextLocation
        # move the associated connections  -  is this needed?
        item.getConnections.each do |c| c.updateCoords end
			}
		)

		self.add( 'command', 'label' => "connect", 
			'command' => proc { 
        editor.setState UCConnectItem.new( editor)
			} 
		)

    # how to render a canvas item invisible
    self.add( 'command', 'label' => "transparent",
			'command' => proc {
        i = editor.getCurrentItem
        i.setinvisible
        # i.getConnections.each do |c| c.setinvisible end
			}
		)

    # how to render a canvas item invisible
    self.add( 'command', 'label' => "visible",
			'command' => proc {
        i = editor.getCurrentItem
        i.setvisible
			}
		)

		self.add( 'command', 'label' => "remove", 
			'command' => proc { 
        i = editor.getCurrentItem
				if i != nil then
					setStatus "remove item #{i} from canvas"
					setEventItem nil
          # i.destruct - current implementation
					i.gettag.destroy
				end
			} 
		)

    self.add( 'command', 'label' => "ungroup",
			'command' => proc {
        i = editor.getCurrentItem
				if i != nil && i.class == UONGroupingBox then
					setStatus "ungroup item #{i}"
					setEventItem nil
          # re-bind item bindings
          i.getList.each { |item|
            if item.class != TkcText then
              puts "ungroup:  item #{item}"
              item.getBindings.each { |p|
                puts "binding name:  #{p[0]}"
                item.bind p[0], p[1]
              }
            end # item is not TkcText
          }

          # destroy group box
          i.destroyText
          i.destroy
				end
			}
		)
	end # method initialize
end # class ItemMenu

# adds a submenu at bottom of Item menu with a list of strings to set the text of the item
# turn off double-click to explicitly insert arbitrary text in the item
class SelectionMenu < ItemMenu
  def initialize( uonEditor, selector_label, selectable_labels)
    super( uonEditor)
		tearoff false
      
    add_cascade( :label => selector_label, :menu => TkMenu.new( self) {
        tearoff false
        ed = uonEditor
        selectable_labels.each do |t|
          add( 'command', 'label' => t,'command' => proc {
            i = ed.getCurrentItem # assert:  i has type UONPrimitive
            i.setText t
            ed.setStatus "on #{i}:  selected #{t}"
			    }
		      )
        end
      }
    )
  end # method initialize
end # class SelectionMenu

class ConnectionMenu < ItemMenu
  def initialize( uonEditor)
    super( uonEditor)
    
    self.add( 'command', 'label' => "toggle source",
			'command' => proc {
        c = getEventItem()
        if c != nil then
          c.toggleSource
        end
			}
		)

    self.add( 'command', 'label' => "toggle dest",
			'command' => proc {
        c = getEventItem()
        if  c != nil then
          c.toggleDestination
        end
			}
		)
  end # def initialize
end # class ConnectionMenu
