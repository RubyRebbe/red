# require 'uonObject'
# require 'uonEditor'

=begin
  UCaseFactory creates a use case .rb file based upon the following structure:
    * the Use case
    * the mouse event
    * both item and canvas may respond to the same mouse event,
      if so, the item responds first, then the canvas (that is the tk rule)

  This is highly meta-programming!
=end
class UCaseFactory
  def initialize( uonEditor)
    @editor = uonEditor
    
    @usecases = [
      "UCBase", "UCResizeItem", "UCConnectItem", "UCEditItemText"
    ]

    @canvasMouseEvents = uonEditor.getModelCanvas.bindinfo.map { |z| z.gsub( "-", "") }

    i = UONObject.new( uonEditor.getModelCanvas, 0, 0, 0, 0, uonEditor)
    @itemMouseEvents = i.bindinfo.map { |z| z.gsub( "-", "") }
    i.destroy
  end

  def getItemMouseEvents
    @itemMouseEvents
  end

  def getCanvasMouseEvents
    @canvasMouseEvents
  end

  def getUCases
    @usecases
  end

  # returns string of ruby code, which can be executed or stored in a ruby file
  def createUCases
    r = ""
    @usecases.each { |ucase|
      r = r + "\n" + createUcase( ucase)
    }
    r
  end
  
  # creates the ruby text for a class which represents an editor use case
  def createUcase( ucaseName)
    base = (ucaseName == "UCBase") ? "" : " < UCBase "
    retval = "\t\treturn self\n"
    arglist = "( event)"
    constructor = "\tdef initialize( uonEditor)\n\t\t@editor = uonEditor\n\tend\n\n"
    edGetter = "\tdef getEditor\n\t\t@editor\n\tend\n\n"

    r = "class " + ucaseName + base + "\n"
    if ucaseName == "UCBase" then r = r + constructor + edGetter end

    @itemMouseEvents.each { |e|
      body = @methodBody[ucaseName + "." + "mouse" + e]
      if body == nil then body = "" end
      r = r + "\tdef " + "mouse" + e + arglist + "#{body}\n#{retval}\tend # method #{e} \n\n"
    }

    @canvasMouseEvents.each { |e|
      body = @methodBody[ucaseName + "." + "canvas" + e]
       if body == nil then body = "" end
      r = r + "\tdef " + "canvas" + e + arglist + "#{body}\n#{retval}\tend # method #{e}\n\n"
    }

    r = r + "end # class #{ucaseName}\n"
    r
  end

  def createUCaseFile( useCaseFileName)
    # now, write out the batch of use cases to a file
    # useCaseFileName = "redusecases.rb"
    f = File.new( useCaseFileName, "w")
    f.write self.createUCases
    f.close
  end
end # class UCaseFactory