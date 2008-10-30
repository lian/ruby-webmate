require File.dirname(__FILE__) + '/resources.rb'

class RenderEngine
  def self.run(page);new(page).run;end
end

class RenderEngine
  attr_accessor :cache, :page
  def initialize(page)
    @page = page
    @cache = {}
    @resources = RenderEngineResources.new(self)
  end
  
  def run
    render_page
    render_layout
    render_html
  end
  
  def render_page
    @cache[:page] ||= @page.render_erb( get_resources_binding )
  end
  
  def render_layout
    @cache[:layout] ||= render_layout_erb
  end
  
  def render_html
    @cache[:html] ||= eval(ERB.new(HTML_TEMPLATE).src, get_resources_binding )
  end
  
  def get_resources_binding
    @resources.get_binding
  end

  def render_layout_erb
    layout_name = @page.resources.layout || "default"
    layout_path = "#{@page.project.path}/pages/_layout/#{layout_name}.erb"
    if File.exists?(layout_path)
      content = open(layout_path).read
      eval(ERB.new(content).src, get_resources_binding )
    else
      render_page
    end
  end
end

HTML_TEMPLATE = %{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title><%= @page.project.name %> - <%= @page.name.capitalize %></title>

<%= load_development_envoirment %>

<%= require_javascripts %>

<%= require_stylesheets %>

</head>
<body>
<%= render_layout %>
</body>
</html>}