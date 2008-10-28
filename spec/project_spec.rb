require File.dirname(__FILE__) + '/spec_helper.rb'

describe WebProject do
  
  describe "when created" do
    before(:each) do
      @project_name = "rspec_project_created"
      @project_path = Webmate.projects_path+"/#{@project_name}"
      remove_rspec_dir(@project_path)
      @project = WebProject.create @project_name
    end
    
    it "should create default files and directory structure" do
      @project.class.should == WebProject
      (WebProject::DIR_STRUCTURE + WebProject::FILE_STRUCTURE).each do |path|
        File.exists?(@project_path+"/#{path}").should == true
      end
    end
    
    it "should create git repository of project" do
      File.exists?(@project_path+"/.git").should == true
    end
    
    it "should add index.erb page" do
      @project.pages.first.should == "index"
    end

    it "should add layout.erb layout" do
      @project.layouts.first.should == "layout"
    end
    
    it "should add default.css stylesheet" do
      @project.stylesheets.first.should == "default"
    end
    
    it "should add default.js javascript" do
      @project.javascripts.first.should == "default"
    end
  end

  describe "when initialized" do
    before(:each) do
      @project_name = "rspec_project_initialized"
      @project_path = Webmate.projects_path+"/#{@project_name}"
      remove_rspec_dir(@project_path)
      @project = WebProject.create @project_name
    end
    
    it "should initialize project.meta" do
      @project.meta.should_not == nil
      @project.meta.class.should == Hash
    end

    it "should be able to return title of project" do
      @project.meta["project_title"].should == @project_name
    end
    
    it "should be able to return type of project" do
      @project.meta["project_type"].should == "web"
    end

    it "should be able to return directory path of project" do
      @project.path.should == @project_path
    end

    it "should be able to list pages of project" do
      @project.pages.class.should == Array
      @project.pages.size.should > 0
    end
    
    it "should be able to list layouts of project" do
      @project.layouts.class.should == Array
      @project.layouts.size.should > 0
    end

    it "should be able to list stylesheets of project" do
      @project.stylesheets.class.should == Array
      @project.stylesheets.size.should > 0
    end
    
    it "should be able to list javascripts of project" do
      @project.javascripts.class.should == Array
      @project.javascripts.size.should > 0
    end
    
  end
  
end # WebProject