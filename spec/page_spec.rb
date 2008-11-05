require File.dirname(__FILE__) + '/spec_helper.rb'

describe WebPage do
  before(:each) do
    @project_name = "rspec_project_page_tests"
    @project_path = Webmate.projects_path+"/#{@project_name}"
    remove_rspec_dir(@project_path)
    @project = WebProject.create @project_name
    @page = WebPage.new "index", @project
  end

  # describe "when creating new page" do
  #   before(:each) do
  #     @project.page_create "foobar"
  #   end
  #   it "should add page to project" do
  #     @project.pages.size.should == 2
  #     @project.pages.include?("foobar").should == true
  #   end
  # end
  
  it "should initalize project" do
    @page.project.should ==  @project
  end

  it "should be able to return name of page" do
    @page.name.should ==  "index"
  end


  it "should be able to list stylesheets of page" do
    @page.resources.stylesheets.class.should == Array
    #@page.stylesheets.size.should > 0
  end
  
  it "should be able to list javascripts of page" do
    @page.resources.javascripts.class.should == Array
    #@page.javascripts.size.should > 0
  end

  it "does your work."
end
