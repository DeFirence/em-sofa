require './spec_helper'

module EventMachine::Sofa

describe Version do
  it "should get version" do
    Version::STRING.should == "#{Version::MAJOR}.#{Version::MINOR}.#{Version::PATCH}"
  end
end

end
