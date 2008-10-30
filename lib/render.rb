class WebmateRender
  def initialize(page)
    @page = page
    @load_log = []
  end
  def erb_path; @page.project.path+"/pages/#{@page.name}.erb"; end

  def render_content;render_page_content;end

  def render_html
    render_page_with_layout
    html = eval(ERB.new(HTML_TEMPLATE).src, @layout.get_binding)
  end

  def render_page_with_layout
    layout_name = @page.resources.layout || "default"
    layout_path = "#{@page.project.path}/pages/_layout/#{layout_name}.erb"
    if File.exists?(layout_path)
      @layout = LayoutHelper.new @page
      content = open(layout_path).read
      @layout_rendered = eval(ERB.new(content).src, @layout.get_binding)
    else
      @layout_rendered = @page.render_erb
    end
  end

  def render_page_content
    @page.render_erb
  end
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

module HTMLResourcesHelper
  def require_javascripts
    html = (@resources[:javascript] + @page.resources.javascripts).collect { |js|
      if @page.project.javascripts.include?(js)
        %{<script src="/project/#{@page.project.name}/js/#{js}.js" type="text/javascript" charset="utf-8"></script>}
      elsif lib = JavascriptBundle.find(js)
        lib.render_html
      end
    }.join("\n")
    [%{<!-- require_javascripts: begin -->}, html, %{<!-- require_javascripts: end -->}].join("\n")
  end
  
  def load_development_envoirment
    html = %w{extjs ruby-js growl}.collect { |i|
      if lib = JavascriptBundle.find(i)
        lib.render_html
      end
    }.join("\n")
    [%{<!-- development_envoirment: begin -->}, html + %{<!-- development_envoirment: end -->}].join("\n")
  end

  def require_stylesheets
    html = (@resources[:stylesheet] + @page.resources.stylesheets).collect { |css|
      %{<link rel="stylesheet" type="text/css" href="/project/#{@page.project.name}/css/#{css}.css" />}
    }.join("\n")
    [%{<!-- require_stylesheets: begin -->}, html, %{<!-- require_stylesheets: end -->}].join("\n")
  end
end


class LayoutHelper
  attr_accessor :resources
  def initialize(page)
    @page = page
    @resources = { :javascript => [], :stylesheet => [], :layout => nil }
  end

  include PageResourcesHelper
  include HTMLResourcesHelper

  def render_page_content;@page.render_erb;end
  def render_content;render_page_content;end
  def render_page_with_layout
    render_page_content
    layout_name = @page.resources.layout || "default"
    
    layout_path = "#{@page.project.path}/pages/_layout/#{layout_name}.erb"
    if File.exists?(layout_path)
      content = open(layout_path).read
      eval_out = eval(ERB.new(content).src, get_binding)
    else
      eval_out = render_page_content
    end
    [%{<!-- layout: '#{layout_name}' begin -->}, eval_out, %{<!-- layout: '#{layout_name}' end -->}].join("\n")
  end

  def get_binding;binding;end
  def inspect;@resources.inspect;end
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
<%= render_page_with_layout %>
</body>
</html>}