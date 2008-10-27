class WebProject
  attr_accessor :path, :meta
  def initialize(path)
    @path = path
    init_config
  end
  
  def init_config
    @meta ||= {}
    @meta = YAML.load_file("#{@path}/project.meta")
  end
  
  def pages
    Dir[@path+"/pages/*.erb"].collect { |i| File.basename(i).gsub(".erb","") }
  end
  def layouts
    Dir[@path+"/pages/_layout/*.erb"].collect { |i| File.basename(i).gsub(".erb","") }
  end
  
  
end

class WebProject
  DIR_STRUCTURE = ["","pages","pages/_layout","pages/_partial","resources","resources/css","resources/js","resources/media"]
  FILE_STRUCTURE = ["pages/index.erb","pages/_layout/layout.erb","resources/css/default.css","resources/js/default.js"]
  
  def self.generate_default_files_and_directories(project_path)
    DIR_STRUCTURE.each  { |dir_path| tmp_path = "#{project_path}/#{dir_path}"; Dir.mkdir(tmp_path) unless File.exists?(tmp_path) }
    FILE_STRUCTURE.each { |file_path| tmp_path = "#{project_path}/#{file_path}"; File.open(tmp_path,"wb") { |f| f.print "" } unless File.exists?(tmp_path) }
    project_meta = { 'project_title' => File.basename(project_path), 'project_type' => 'web' }
    File.open(project_path+"/project.meta","wb") { |f| f.print project_meta.to_yaml }
    self.initialize_git(project_path, project_meta)
    [project_path, project_meta]
  end

  def self.initialize_git(path,meta)
    unless File.exists?(path+"/.git")
      Dir.chdir(path)
      system "git init > /dev/null 2>&1"
      system "git add project.meta > /dev/null 2>&1"
      system "git commit -m 'init #{meta['project_title']} project' > /dev/null 2>&1"
    end
  end

  def self.create(name)
    project_path = Webmate.projects_path+"/#{name}"
    new_path, meta = self.generate_default_files_and_directories(project_path) unless File.exists?(project_path)
    project_path = new_path if new_path
    new project_path
  end
end
