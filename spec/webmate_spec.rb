require File.dirname(__FILE__) + '/spec_helper.rb'

describe Webmate do
  it "should return projects_path" do
    Webmate.projects_path.should == $projects_path
  end
  it "should be able to set projects_path" do
    test_path = "/tmp/ruby-webmate-projects_path-spec"
    remove_rspec_dir test_path
    File.exists?(test_path).should == false
    Webmate.projects_path(test_path).should == test_path
    File.exists?(test_path).should == true
  end
end

#remove_rspec_dir $projects_path