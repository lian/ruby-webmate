require "git"

class WebProjectGit
  def initialize(project)
    @project = project
    init_git
  end
  
  def init_git
    if File.exists?(@project.path+"/.git")
      @git = Git.open(@project.path)
    else
      @git = Git.init(@project.path)
    end
  end
  
  def last_commit
    log = `git log master -1`.split("\n")
    { 
      :commit => log[0].gsub("commit ",''),
      :author => log[1].gsub("Author: ",''),
      :date => log[2].gsub("Date:  ",''),
    } if log
  end
  
  def file_modified?(file_path)
    @git.diff.each { |file| return file.path if file_path == file.path };nil
  end
  def page_modified?(name); file_modified?("pages/#{name}.erb"); end
  
  def commit_page(name)
    if path = page_modified?(name)
      @git.add(path)
      @git.commit("edit page: #{name}")
    end
  end
  
end