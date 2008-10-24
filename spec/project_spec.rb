require File.dirname(__FILE__) + '/spec_helper.rb'


describe WebProject do
  describe "when created" do
    it "should create default files and directory structure" do
      project_name = "rspec_create_files_and_directories"
      project_path = Webmate.projects_path+"/#{project_name}"
      remove_rspec_dir(project_path)
      project = WebProject.create project_name
      
      project.class.should == WebProject
      (WebProject::DIR_STRUCTURE + WebProject::FILE_STRUCTURE).each do |path|
        File.exists?(project_path+"/#{path}").should == true
      end
    end
    
    it "should create git repository of project" do
      project_name = "rspec_create_git_repo"
      project_path = Webmate.projects_path+"/#{project_name}"
      remove_rspec_dir(project_path)
      project = WebProject.create project_name
      
      File.exists?(project_path+"/.git").should == true
    end
  end
  
  describe "when initialized" do
    before(:each) do
      @project_name = "rspec_project_initialized"
      @project_path = Webmate.projects_path+"/#{@project_name}"
      remove_rspec_dir(@project_path)
    end
    
    it "should initialize project.meta" do
      @project = WebProject.create @project_name
      @project.meta.should_not == nil
      @project.meta.class.should == Hash
    end

    it "should be able to return title of project" do
      @project = WebProject.create @project_name
      @project.meta["project_title"].should == @project_name
    end
    
    it "should be able to return type of project" do
      @project = WebProject.create @project_name
      @project.meta["project_type"].should == "web"
    end

    it "should be able to return directory path of project" do
      @project = WebProject.create @project_name
      @project.path.should == @project_path
    end
  end
  
end
