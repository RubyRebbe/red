# uonactor_spec.rb
# establish a behavior, write a test to test it, write the code to implement it, refactor
# run rspec at root of project, and name the test directory spec

# require 'tk'

require "uonactor.rb"
require "tkccontainer.rb"

describe UONActor, " is the glyph for an actor in a use case" do
	before( :each) do
		@actor = UONActor.new
	end

	it " inherits from TkcContainer" do
		@actor.class.superclass.should == TkcContainer
	end
end
