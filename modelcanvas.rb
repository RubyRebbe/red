#!/usr/bin/ruby

require 'yaml'
require 'tk'
require 'uonObject.rb'
require 'uonMenu.rb'
require 'redusecases.rb'
require 'ucasefactory.rb'

# ModelCanvas implicitly contains a list of its contents:  self.find( "all") returns array of items
class ModelCanvas < TkCanvas
	attr_accessor :editor, :eventItem, :srcItem, :destItem

	def initialize( uonEditor)
		super( uonEditor)
		self.editor = uonEditor
    
		place( "relwidth" => 1.0, "relheight" => 0.92)

		bind( "ButtonPress-3") do |event|
			editor.setState editor.getState.canvasButton3 event
		end # bind ButtonPress-3

		bind( "ButtonPress-1") do |event|
			editor.setState editor.getState.canvasButton1 event
		end  # bind event ButtonPress

		bind( "Motion") do |event|
			editor.setState editor.getState.canvasMotion event
		end # bind event Motion

		bind( "ButtonRelease") do |event|
			editor.setState editor.getState.canvasButtonRelease event
		end # bind event ButtonRelease
    # what are all the bindings to the canvas:  self.bindinfo
	end # initialize

	# is the event position in the bbox of the item?
	def isin?( i, e)
		b = i.bbox
		(b[0] <= e.x) && (e.x <= b[2])  && (b[1] <= e.y) && (e.y <= b[3])
	end

	def setStatus( statusString)
		statusField = editor.getStatus
		statusField.clear
		statusField.insert( "end", statusString)
	end # method setStatus

	# return list of all items in canvas which match class klass
	def getItems( klass)
		r = []
		self.find( "all").each do |item|
			if item.class == klass then
				r.push item
			end
		end
		r
	end # method getItems

	# home-grown serialization of canvas model
  # 11 june 2009: fix to account for addition of termini in UONConnection
	# 19 june 2011: need to analyze passivate and activate tags!
	def serialize
		sItems, sConnections, connections = [], [], getItems(UONConnection)
    items = []; self.find( "all").each { |i|
      items << i unless ((i.class == TkcText) || (i.class == UONConnection))
    }

    # passivate items
    items.each { |i| sItems << i.to_serialize }

		# convert addresses of connected items into indices into the items array
		connections.each do |c|
			# assert: forall c: items.index() != nil
			sConnections.push [ # serialized version of connection.  issue: fill color of line
				c.class, c.getText, items.index( c.srcItem), items.index( c.destItem), c.fill
			]
		end

		[ sItems, sConnections] # return serialized model
	end # method serialize

	# 19 June 2011:  what if anything must this method do about tags?
	def deserialize(  serializedModel)  # elegance is using Ruby itself as the serialization language!
		smodel = self.instance_eval serializedModel
		sItems, sConnections = smodel[0], smodel[1]  # unpack the serialized model in items and connections
		# deserialize the model, item list first
		items = []; sItems.each { |i| items.push( instance_eval( i)) }

		# deserialize the connections
    # 11 june 2009:  fix to account for new form of constructor
    connections = []
		sConnections.each do |c| 			# [ class, text, srcIndex, destIndex ]
			conn = c[0].new( editor.getModelCanvas, 0, 0, 0, 0, editor, items[c[2]], items[c[3]]) do
				setText c[1]; fill c[4]; updateCoords; lower
			end
      connections << conn
		end # for each connection in sConnections
	end # method deserialize
end  # class ModelCanvas
