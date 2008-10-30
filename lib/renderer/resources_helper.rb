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