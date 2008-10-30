class WebPage
  def self.create(name,project)
    file_path = project.path+"/pages/#{name}.erb"
    unless project.pages.include?(name)
      File.open(file_path,"wb") { |f| f.print "<!-- page: #{name} -->" }
      system "git add #{file_path} > /dev/null 2>&1"
      system "git commit -m 'new_page: #{File.basename file_path}' > /dev/null 2>&1"
    end
    new(name, project) if File.exists?(file_path)
  end
end

class WebPage
  attr_accessor :name, :project, :render, :resources
  def initialize(name,project)
    @name = name
    @project = project
    #@render = WebmateRender.new self
    @resources = PageResources.new
    refresh_resources
  end
  
  def render_erb(passed_binding=nil)
    content = open( erb_path ).read
    eval(ERB.new(content).src, (passed_binding || @resources.get_binding) )
  end
  
  def refresh_resources;render_erb;true;end
  def erb_path; @project.path+"/pages/#{@name}.erb"; end
end