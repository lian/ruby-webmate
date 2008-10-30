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
    @render = WebmateRender.new self
    @resources = PageResources.new
    refresh_resources
  end
  
  def render_erb
    content = open( erb_path ).read
    eval(ERB.new(content).src, @resources.get_binding )
  end

  def refresh_resources;render_erb;true;end

  def erb_path; @project.path+"/pages/#{@name}.erb"; end
end

module PageResourcesHelper
  def layout(name=nil);
    @resources[:layout] = name if name
    @resources[:layout]
  end
  
  def javascript(name) require_resources :javascript, name; end
  def javascripts;@resources[:javascript].uniq;end

  def stylesheet(name) require_resources :stylesheet, name; end
  def stylesheets;@resources[:stylesheet].uniq;end

  def partial(name) require_resources :partial, name; end
  def partials;@resources[:partial].uniq;end
  
  def require_resources(type,resources=[])
    case resources.class
    when Array
      resources.each { |resource_name| @resources[type] << resource_name.to_s unless @resources[type].include?(resource_name.to_s) }
    else
      @resources[type] << resources.to_s unless @resources[type].include?(resources.to_s)
    end
  end
end

class PageResources
  attr_accessor :resources
  def initialize
    @resources = { :javascript => [], :stylesheet => [], :layout => nil }
  end
  
  include PageResourcesHelper
  
  def get_binding;binding;end
  def inspect;@resources.inspect;end
end
