require 'rspec'
require_relative '../app/controllers/parses_controller'

describe ParsesController do

  before :each do
    @parses = Parse.all
  end

  describe "#index"
  it "take the params and set them to the object" do
     	@parses.should be
  end


end