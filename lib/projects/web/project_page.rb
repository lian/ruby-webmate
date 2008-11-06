class WebPage
  attr_accessor :name, :project, :render, :resources
  def initialize(name,project)
    @name = name
    @project = project
    #@render = WebmateRender.new self
    @resources = PageResources.new self
    refresh_resources
  end
  
  def render_erb(passed_binding=nil)
    content = open( erb_path ).read
    eval(ERB.new(content).src, (passed_binding || @resources.get_binding) )
  end
  
  def refresh_resources;render_erb;true;end
  def erb_path; @project.path+"/pages/#{@name}.erb"; end
end

# class PageResources
#   attr_accessor :resources
#   def initialize
#     @resources = { :javascript => [], :stylesheet => [], :layout => nil }
#   end
#   
#   include PageResourcesHelper
#   
#   def get_binding;binding;end
#   def inspect;@resources.inspect;end
# end
