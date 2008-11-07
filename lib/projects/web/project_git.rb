require "git"

class WebProjectGit
  def initialize(project)
    @project = project
    init_git
  end
  
  def self.initialize_git(path,meta)
    if File.exists?(path)
      git = Git.init(path) 
      WebProject::FILE_STRUCTURE.each { |file| git.add file }
      git.commit("new project: #{meta['project_title']}")
    end
  end
  
  def init_git
    @git = File.exists?(@project.path) ? Git.open(@project.path) : Git.init(@project.path)
  end
  
  def last_commit
    log = `git log master -1`.split("\n")
    if log
      { 
        :commit => log[0].gsub("commit ",''),
        :author => log[1].gsub("Author: ",''),
        :date => log[2].gsub("Date:  ",''),
      } 
    end
  end
  
  def modified_page_resource(page)
    modified, js, css, layout =  { }, page.resources.javascripts, page.resources.stylesheets, (page.resources.layout || "default")
    @git.diff.each do |file|
      case file.path
        when "pages/#{page.name}.erb"
          modified[:page] = true
        when "pages/_layout/#{layout}.erb"
          modified[:layout] = true
        when "resources/css/default.css"
            modified[:stylesheet] ||= []
            modified[:stylesheet] << "default"
        when "resources/js/default.js"
            modified[:javascript] ||= []
            modified[:javascript] << "default"
        when /resources\/js/
          if js.include? file.path.split("/").last.gsub(".js","")
            modified[:javascript] ||= []
            modified[:javascript] << file.path.split("/").last.gsub(".js","")
          end
        when /resources\/css/
          if css.include? file.path.split("/").last.gsub(".css","")
            modified[:stylesheet] ||= []
            modified[:stylesheet] << file.path.split("/").last.gsub(".css","")
          end
      end
    end
    (modified.size > 0) ? modified : nil
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

  def commit(name,type,commit_msg=nil)
    case type.to_s
    when "page"
      if path = file_modified?("pages/#{name}.erb")
        @git.add(path)
        @git.commit(commit_msg || "changed page: #{name}")
      end
    when "javascript"
      if path = file_modified?("resources/js/#{name}.js")
        @git.add(path)
        @git.commit(commit_msg || "changed javascript: #{name}")
      end
    when "stylesheet"
      if path = file_modified?("resources/css/#{name}.css")
        @git.add(path)
        @git.commit(commit_msg || "changed stylesheet: #{name}")
      end
    when "layout"
      if path = file_modified?("pages/_layout/#{name}.erb")
        @git.add(path)
        @git.commit(commit_msg || "changed layout: #{name}")
      end
    end
  end
  
end