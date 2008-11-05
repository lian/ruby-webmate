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