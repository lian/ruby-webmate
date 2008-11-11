require 'rubygems'
require "yaml"
require 'sinatra'
require File.dirname(__FILE__) + "/../webmate.rb"
require File.dirname(__FILE__) + "/../../../github/javascript-bundle.git/lib/adapter/sinatra.rb"
require File.dirname(__FILE__) + "/../../../github/javascript-bundle.git/lib/extjs/adapter/sinatra.rb"

JavascriptBundle::Backend::Sinatra.init
JavascriptBundle::Ext::Backend::Sinatra.init

require File.dirname(__FILE__) + "/extjs/project_window.rb"

Webmate.projects_path "/Users/langschaedel/cc/webmate-projects" # "/Volumes/data/lang/webmate-projects"



## projects routes
get "/" do
  erb :default
end

get "/project/*/" do
  name = params[:splat].first
  if Webmate.projects.include? name
    @project = WebProject.new "#{Webmate.projects_path}/#{name}"
    erb :project_base
  end
end

## project routes
get "/project/*/:page" do
  name = params[:splat].first
  if Webmate.projects.include? name
    @project = WebProject.new "#{Webmate.projects_path}/#{name}"
    if @project.pages.include? params[:page]
      @page = WebPage.new params[:page], @project
      RenderEngine.run @page
    end
  end
end

get "/project/*/css/*" do
  content_type 'text/css', :charset => 'utf-8'
  name, stylesheet_path = params[:splat]
  if Webmate.projects.include? name
    WebProject.load(name).read_stylesheet stylesheet_path
  end
end

get "/project/*/js/*" do
  content_type 'text/javascript', :charset => 'utf-8'
  name, javascript_path = params[:splat]
  if Webmate.projects.include? name
    WebProject.load(name).read_javascript javascript_path
  end
end

get "/project/*/media/*" do
  content_type 'text/css', :charset => 'utf-8'
  name, media_path = params[:splat]
  if Webmate.projects.include? name
    WebProject.load(name).read_media_file media_path
  end
end

## preview routes
get "/preview/project/*/:page" do
  name = params[:splat].first
  if Webmate.projects.include? name
    @project = WebProject.new "#{Webmate.projects_path}/#{name}"
    if @project.pages.include? params[:page]
      @page = WebPage.new params[:page], @project
      #DeployRenderEngine.run @page
      RenderEngine.run @page, :production
    end
  end
end

get "/preview/project/*/css/*" do
  content_type 'text/css', :charset => 'utf-8'
  name, stylesheet_path = params[:splat]
  if Webmate.projects.include? name
    project = WebProject.load(name)
    if project.stylesheets.include? stylesheet_path.gsub(".css","")
      project.read_stylesheet stylesheet_path
    else
      if lib = JavascriptBundle.find(stylesheet_path.split("/")[0])
        lib.read_file(stylesheet_path.split("/")[1..-1].join("/"))
      end
    end
  end
end

get "/preview/project/*/js/*" do
  content_type 'text/javascript', :charset => 'utf-8'
  name, javascript_path = params[:splat]
  if Webmate.projects.include? name
    project = WebProject.load(name)
    if project.javascripts.include? javascript_path.gsub(".js","")
      project.read_javascript javascript_path
    else
      if lib = JavascriptBundle.find(javascript_path.split("/")[0])
        lib.read_file(javascript_path.split("/")[1..-1].join("/"))
      end
    end
  end
end

get "/preview/project/*/media/*" do
  content_type 'text/css', :charset => 'utf-8'
  name, media_path = params[:splat]
  if Webmate.projects.include? name
    WebProject.load(name).read_media_file media_path
  end
end