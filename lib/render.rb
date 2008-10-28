class WebmateRender
  def initialize(page)
    @page = page
    @load_log = []
  end
  def erb_path; @page.project.path+"/pages/#{@page.name}.erb"; end

  # erb helpers
  def require_stylesheets
    @page.stylesheets.collect { |css|
      @load_log << "stylesheet: #{css}.css loaded"
      %{<link rel="stylesheet" type="text/css" href="/project/#{@page.project.name}/css/#{css}.css" />}
    }.join("\n")
  end

  def require_javascripts
    @page.javascripts.collect { |js|
      @load_log << "javascript: #{js}.js loaded"
      %{<script src="/project/#{@page.project.name}/js/#{js}.js" type="text/javascript" charset="utf-8"></script>}
    }.join("\n")
  end
  
  def require_dev_javascripts
    %w{extjs ruby-js growl}.collect { |i|
      @load_log << "dev-script: #{i}.js loaded"
      if lib = JavascriptBundle.find(i)
        lib.render_html
      end
    }.join("\n")
  end

  def render(env)
    case env
    when :development
      render_html
    end
  end
  
  def dev;render(:development);end
  def production;render(:production);end
  def render_content;render_page_content;end

  def render_html
    render_page_with_layout
    html = eval(ERB.new(HTML_TEMPLATE).src, binding)
  end

  def render_page_with_layout
    @layout ||= "default"
    layout_path = "#{@page.project.path}/pages/_layout/#{@layout}.erb"
    if File.exists?(layout_path)
      content = open(layout_path).read
      @load_log << "layout: #{@layout}.erb rendered"
      @layout_rendered = eval(ERB.new(content).src, binding)
    else
      @layout_rendered = render_page_content
    end
  end

  def render_page_content
    content = open( erb_path ).read
    @load_log << "page: #{@title}.erb rendered"
    @page_rendered = eval(ERB.new(content).src, binding)
  end
end

HTML_TEMPLATE = %{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title><%= @page.project.name %> - <%= @page.name.capitalize %></title>

  <!-- require_dev_javascripts: begin -->
  <%= require_dev_javascripts %>
  <!-- require_dev_javascripts: end -->

  <!-- require_javascripts: begin -->
  <%= require_javascripts %>
  <!-- require_javascripts: end -->

  <!-- require_stylesheets: begin -->
  <%= require_stylesheets %>
  <!-- require_stylesheets: end -->

</head>
<body>
<!-- layout: '<%= @layout %>' begin -->
<%= @layout_rendered %>
<!-- layout: '<%= @layout %>' end -->
</body>
</html>}