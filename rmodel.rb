require 'uonObject.rb'
require 'test/unit'  # contains ruby assert

# converting a UON model into a rails app
class RModel
	attr_accessor :project_name

  def initialize( uonItemlist, model_filename = "")
    @uonItemlist = uonItemlist
    @rmodel = []  # the ruby on rails model.  may depreakecate in favor of separate lists below ...
		@rmodel_objects = []
		@rmodel_associations = []
    @project_name = establish_projectname( model_filename)
   
    getuonItems(UONObject).each { |obj|
      # create a corresponding RObject and add to the model
      robject = RObject.new( obj)
      @rmodel_objects << robject
      # find all primitive attributes associated with obj and add to RObject attribute list
      robject.establish_attributes
    }

		establish_associations
		# assert:  @rmodel_associations is filled out
		# elaborate the model by adding in reference attributes in support of the associations
		@rmodel_associations.each { |ra|
			# assert:  ra.connections.length == 2
			belongs_to = ra.getlink( "belongs_to")
			if belongs_to != nil then
				owner_name = belongs_to.farItem.name.downcase # uncapitalize
				link_to_owned = ra.getduallink( "belongs_to")
				if link_to_owned != nil then
					# add a reference attribute into the owned object pointing to the owner
					link_to_owned.farItem.addAttribute RAttribute.new( owner_name, "references")
					# scaffolding generates the supporting db migration for the "belongs_to"
				end
			end
		}
  end # method initialize

  def getuonItemlist
    @uonItemlist
  end

	# maps uonObject to its RObject, or nil
	def to_RObject( uonObject)
		robject = nil
		@rmodel_objects.each { |rob|
			if rob.uonObject == uonObject then
				robject = rob
				break
			end
		}
		robject
	end
 
  # some choices for @project_name: (convention not configure ...)
  #   name of UON model file stripping of .uon etc.
  #   provide a mechanism via condition in the model to specify the top object,
  #   which represents the system as a whole, which may also name the home page for the system
  #   which after all relates to top_controller#index
  def establish_projectname( model_filename)
    mfname = (model_filename == "") ? "" : model_filename.split("/").last.split( ".").first
    (mfname == "") ? "railsproject" : mfname # railsproject is default
  end

  # this method converts the model into a Ruby on Rails script.
  # Use Ruby to execute this script (of shell commands) to create the Rails application
  # first use case:  generate a rails app with a single model object with db attributes
  def to_script
    script = "rails new #{@project_name}" + "\n" + "cd #{@project_name}"
 		# create the database
    script = script + "\n" + "rake db:create"

    @rmodel_objects.each { |o|  # for each rails model object ...
      script = script + "\n" + o.to_script
    }
		
		# what do with do with the informationn in @rmodel_associations?
		# for understanding and testing, we may just want to print them out
		# puts associations_to_script

    # migrate the database
    script = script + "\n" + "rake db:migrate"
    script
  end # method to_script  

	def associations_to_script
		s = "number of RAssociations: #{@rmodel_associations.length}"
		@rmodel_associations.each { |ra| s = s + "\n" + "#{ra}" }
		s
	end

  def getuonItems( klass)
		r = []
		@uonItemlist.each do |item|
			if item.class == klass then
				r.push item
			end
		end
		r
	end # method getItems

  def establish_associations
    getuonItems(UONAssociator).each { |associator|
			rassociation = RAssociation.new( associator, self)
			@rmodel_associations << rassociation
    }
  end # method establish_associations

  def to_s
    s = "Rmodel:"
    @rmodel.each { |o| s = s + "\n" + o.to_s }
    s
  end
end # class RModel

class RAttribute
  attr_accessor :name, :type

  def initialize( n, t)
    @name = n; @type = t
  end

  def to_s
    "RAttribute: name: #{@name}, type: #{@type}"
  end

  def to_script
    "#{@name}:#{@type}"
  end
end # class RAttribute

class RObject
	attr_accessor :uonObject, :name

  def initialize( uonObject)
    @uonObject = uonObject
    @name, @attributeList = uonObject.getText, []
  end
  
  # find all primitive attributes associated with obj and add to RObject attribute list
  def establish_attributes
    @uonObject.getConnections.each { |c|
      if (item = c.getItem( UONPrimitive)) != nil then
        self.addAttribute RAttribute.new( c.getText, item.getText) #( name, type) 
      end
    }
  end # method establish_attributes

  def addAttribute( rattribute)
    @attributeList << rattribute
  end

  def to_s
    s = "RObject name: #{@name}"
    @attributeList.each { |a| s = s + "\n" + a.to_s }
    s
  end

  def to_script
    script = "rails generate scaffold #{@name}"
    @attributeList.each { |a| script = script + " " +  a.to_script }
    script
  end
end # class RObject

# assert @connections.length == 2
class RAssociation # rails association between model objects
	attr_accessor :associator, :connections

	# pre-condition:  associator not nil AND of type UONAssociator	
	def initialize( associator, rmodel = nil)
		@associator = associator
		# map UONObject to RObject
		@connections = @associator.getConnections.map { |c|
			RConnection.new( (@associator == c.srcItem) ? rmodel.to_RObject( c.destItem) : rmodel.to_RObject( c.srcItem), c.getText)
		}
	end

	# returns the Rconnection whose name matches the text, or nil
	def getlink( txt)
		rc = nil
		@connections.each { |c|
			if txt == c.name then
				rc = c; break
			end
		}
		rc
	end

	# returns the other RConnection whose name is NOT txt
	# pre-condition:  getlink( txt) != nil
	def getduallink( txt)
		rc = nil
		@connections.each { |c|
			if txt != c.name then
				rc = c; break
			end
		}
		rc
	end

	def to_s
		s = "# connectors: #{connections.length}"
		@connections.each { |rc| s = s + "\n" + rc.to_s }
		s
	end

	def to_script

	end
end # class RAssociation

# assumption: close end connected to a RAssociation, so only need to store far end object
class RConnection
	attr_accessor :farItem, :name
	
	# issue:  is the far Object of type UONObject or of type RObject
	# in good design, probably should be of type RObject
	# Let's do this in two steps:  first, far Object is of type UONObject, next step RObject
	def initialize( farObject, txt)
		# assert farObject.class == UONObject, "far object is not of type UONObject"
		@farItem, @name = farObject, txt
	end

	def to_s
		"RConnection: text #{@text}, farItem #{@farItem} #{@farItem}"
	end
end # class RConnection

