module EditorServices
	attr_accessor :editor

	def setStatus( t)
		statusField = editor.getStatus
		statusField.clear
		statusField.insert( "end", t)
	end # method setStatus

	def getEventItem
		editor.getModelCanvas.eventItem
	end

	def setEventItem( i)  # pre:  i == nil OR i == self
		editor.getModelCanvas.eventItem = i
	end

	def setSrcItem( i)
		editor.getModelCanvas.srcItem = i
	end

	def getSrcItem
		editor.getModelCanvas.srcItem
	end
end # module EditorServices

