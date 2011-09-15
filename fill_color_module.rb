require 'tk'
require 'editorServices.rb'

module FillColorModule
  # don't know what the right initial value is ...
  @fillcolor = "white"

  def getfillcolor
    @fillcolor
  end

  def setfillcolor( color)
    @fillcolor = color
  end

  def setinvisible
    # will need to save previous fill color in order to restore it
    setfillcolor self.fill
    background = editor.getModelCanvas.background
    self.fill background
    self.outline background
    # now render text invisible:  default color is black
    self.getTextItem.fill background
  end

  def setvisible
    # restore fill color
    self.fill self.getfillcolor
    # restore outline color
    self.outline 'black' # needs to be purple for a group ...
    # restore text fill color
    self.getTextItem.fill 'black'
  end
end
