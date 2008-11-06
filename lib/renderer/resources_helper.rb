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
    list = (@page.resources.javascripts.size == 0) ? ["default"] : @page.resources.javascripts
    html = (@resources[:javascript] + list).uniq.collect { |js|
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
    [%{<!-- development_envoirment: begin -->}, html + %{<!-- development_envoirment: end -->}, load_development_scripts].join("\n")
  end

  def require_stylesheets
    list = (@page.resources.stylesheets.size == 0) ? ["default"] : @page.resources.stylesheets
    html = (@resources[:stylesheet] + list).uniq.collect { |css|
      %{<link rel="stylesheet" type="text/css" href="/project/#{@page.project.name}/css/#{css}.css" />}
    }.join("\n")
    [%{<!-- require_stylesheets: begin -->}, html, %{<!-- require_stylesheets: end -->}].join("\n")
  end
  
  def load_development_scripts
    %{
<script type="text/javascript" charset="utf-8">
      var project_window = null;

      document.onkeydown = function(event){
      	if ((event.keyCode == 73) && (event.ctrlKey)) {
      	  
      	   if (!project_window) {
             Rb.request("/javascript-bundle-ext/project_window/init?project=#{@page.project.name}&page=#{@page.name}")
      	   } else {
      	  	if (project_window.hidden) {
      	      project_window.show(document.body);
      	      Rb.request("/javascript-bundle-ext/project_window/init?project=#{@page.project.name}&page=#{@page.name}")
      	  	} else {
      	     	project_window.hide()
      	  	}
      	   }
      	  //event.cancelBubble = true; event.keyCode = false;
      	  event.returnValue = false;
      	  return false;
      	}

      	if ((event.keyCode == 69) && (event.ctrlKey)) {
      		//Rb.project_request("sitemap_window/edit?type=page&name="+document.body.id);
          Rb.request("/javascript-bundle-ext/project_window/edit?project=#{@page.project.name}&type=page&name=#{@page.name}")
      	}

      }
</script>
    }
  end
  
  def render_git_status
    div = { :class => "" }
    html = ""
    if @page.project.git.page_modified?(@page.name)
      div[:class] = "yellow"
      commit_action = %{Rb.request('/javascript-bundle-ext/project_window/commit?type=page&name=#{@page.name}&project=#{@page.project.name}')}
      html += %{modified: #{@page.name}.erb - <a href="#"" onclick="#{commit_action}">commit</a>}
    else
      div[:class] = "green"
      html += "unchanged: #{@page.name}.erb - "
      html += @page.project.git.last_commit.inspect
    end
    %{<div class="#{div[:class]}" style="border:#{div[:class]} 1px solid; padding:10px" id="webmate_page_git_status">#{html}</div>}
  end
  
end
