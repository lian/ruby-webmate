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
  
  attr_accessor :name, :project
  def initialize(name,project)
    @name = name
    @project = project
  end

  def page_stylesheets
    []
  end

  def stylesheets
    @project.stylesheets+page_stylesheets
  end
  
  def page_javascripts
    []
  end
  
  def javascripts
    @project.stylesheets+page_javascripts
  end  
  
end