class WebProjectDeploy
  def initialize(project, deploy_target=nil)
    @project, @target = project, (deploy_target || project.meta['deploy_to'])
    init_target
  end
  def init_target
    raise "target missing" unless @target && File.exists?( File.dirname(@target) )
    Dir.mkdir(@target) unless File.exists?(@target)
    raise "target missing" unless File.exists?(@target)
    true
  end
  def build_pages
    @missing_jsbundle_resources = []
    project_resources = (@project.javascripts + @project.javascripts)
    
    puts "building #{@project.name} pages: started.."
    @project.pages.each { |page|
      page = WebPage.new(page, @project)
      page_name = "#{page.name.downcase}.html"
      @missing_jsbundle_resources += ( (page.resources.javascripts + page.resources.stylesheets) - project_resources )
      
      if File.exists?(@target)
        html = RenderEngine.run(page, :production)
        File.open("#{@target}/#{page_name}","wb") {|f| f.print(html) }
        puts "deployed #{page_name} => #{@target} ( ok )"; true
      end
    }
    puts "building #{@project.name} pages: finished!";true
  end
  def copy_resources
    %w{js css media}.collect { |name| Dir.mkdir("#{@target}/#{name}") unless File.exists?("#{@target}/#{name}") }
    @project.stylesheets.each { |css| FileUtils.cp "#{@project.path}/resources/css/#{css}.css", "#{@target}/css/#{css}.css" }
    @project.javascripts.each { |js| FileUtils.cp "#{@project.path}/resources/js/#{js}.js", "#{@target}/js/#{js}.js" }
    copy_jsbundle_resources
    copy_media_resources
  end
  def copy_jsbundle_resources
    @missing_jsbundle_resources.each { |resource_name|
      if lib = JavascriptBundle.find(resource_name)
        lib.deploy_to "#{@target}/js"
        puts "deployed #{resource_name} resource to #{@target}"; true
      end
    };true
  end
  def copy_media_resources
    target_media = @target+"/media"
    Dir.mkdir(target_media) unless File.exists?(target_media)
    Dir["#{@project.path}/resources/media/*"].each { |file|
      FileUtils.cp_r file, "#{target_media}/#{File.basename file}"
    };true
  end
  def deploy!
    return nil unless File.exists?(@target)
    build_pages
    copy_resources
    # commit_depoly # if deploy folder is a git repo
    true
  end
end