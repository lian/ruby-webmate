require 'rubygems'
require "yaml"
require 'sinatra'
require File.dirname(__FILE__) + "/../webmate.rb"
require File.dirname(__FILE__) + "/../../../github/javascript-bundle.git/lib/adapter/sinatra.rb"
require File.dirname(__FILE__) + "/../../../github/javascript-bundle.git/lib/extjs/adapter/sinatra.rb"

JavascriptBundle::Backend::Sinatra.init
JavascriptBundle::Ext::Backend::Sinatra.init

require File.dirname(__FILE__) + "/extjs/project_window.rb"

Webmate.projects_path "/Volumes/data/lang/webmate-projects"



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

get "/preview/project/*/:page" do
  # ..
  # RenderEngine.run @page, :production
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
