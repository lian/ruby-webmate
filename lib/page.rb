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

  #def page_stylesheets
  #  @resources.stylesheets
  #end

  #def stylesheets
  #  @project.stylesheets+page_stylesheets
  #end
  
  #def page_javascripts
  #  @resources.javascripts
  #end
  
  # def javascripts
  #   @project.stylesheets+page_javascripts
  # end  

  def erb_path; @project.path+"/pages/#{@name}.erb"; end
end


class PageResources
  attr_accessor :resources
  def initialize
    @resources = { :javascript => [], :stylesheet => [], :layout => nil }
  end
  def layout(name=nil);
    @resources[:layout] = name if name
    @resources[:layout]
  end
  def javascript(name)
    @resources[:javascript] << name unless @resources[:javascript].include?(name)
  end
  def javascripts;@resources[:javascript];end
  def stylesheet(name);
    @resources[:stylesheet] << name unless @resources[:stylesheet].include?(name)
  end
  def stylesheets;@resources[:stylesheet];end
  
  def inspect;@resources.inspect;end
  def get_binding;binding;end
end
