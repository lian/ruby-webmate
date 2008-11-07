module PageResourcesHelper
  def layout(name=nil);
    @resources[:layout] = name if name
    @resources[:layout]
  end
  
  def javascript(*args) require_resources :javascript, args; end
  def javascripts;@resources[:javascript].uniq;end

  def stylesheet(*args) require_resources :stylesheet, args; end
  def stylesheets;@resources[:stylesheet].uniq;end

  def partial(name) require_resources :partial, name; end
  def partials;@resources[:partial].uniq;end
  
  def require_resources(type,resources=[])
    case resources
      when Array
        resources.each { |resource_name| @resources[type] << resource_name.to_s unless @resources[type].include?(resource_name.to_s) }
      else
        @resources[type] << resources.to_s unless @resources[type].include?(resources.to_s)
    end
  end
end

module HTMLResourcesHelper
  def require_javascripts
    page_js = (@page.resources.javascripts.size == 0) ? ["default"] : @page.resources.javascripts
    layout_js = @resources[:javascript].select { |i| !page_js.include?(i) }
    html = (layout_js + page_js).uniq.collect { |js|
      if @project.javascripts.include?(js)
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
    page_css = (@page.resources.stylesheets.size == 0) ? ["default"] : @page.resources.stylesheets
    layout_css = @resources[:stylesheet].select { |i| !page_css.include?(i) }
    html = (layout_css + page_css).uniq.collect { |css|
      if @project.stylesheets.include?(css)
        %{<link rel="stylesheet" type="text/css" href="/project/#{@page.project.name}/css/#{css}.css" />}
      elsif lib = JavascriptBundle.find(css)
        lib.render_html
      end
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

  #def render_git_status
  #  if status = @page.project.git.modified_page_resource(@page)
  #    %{ #{status.inspect} }
  #  else
  #    %{no it status}
  #  end
  #end

  def render_git_status
    div = { :class => "" }
    html = ""
    if status = @page.project.git.modified_page_resource(@page)
      # puts html += %{debug_modified: #{status.inspect}<hr />}
      div[:class] = "yellow"
      if status[:page]
        commit_action = %{Rb.request('/javascript-bundle-ext/project_window/commit?type=page&name=#{@page.name}&project=#{@page.project.name}&page=#{@page.name}')}
        diff_action = %{Rb.request('/javascript-bundle-ext/project_window/commit?type=page&name=#{@page.name}&project=#{@page.project.name}&page=#{@page.name}')}
        html += %{modified: #{@page.name}.page - <a href="#"" onclick="#{commit_action}">commit</a> | <a href="#"" onclick="#{diff_action}">diff</a><br />}
      end
      if status[:stylesheet]
        status[:stylesheet].each { |stylesheet_name|
          commit_action = %{Rb.request('/javascript-bundle-ext/project_window/commit?type=stylesheet&name=#{stylesheet_name}&project=#{@page.project.name}&page=#{@page.name}')}
          diff_action = %{Rb.request('/javascript-bundle-ext/project_window/commit?type=stylesheet&name=#{stylesheet_name}&project=#{@page.project.name}&page=#{@page.name}')}
          html += %{modified: #{stylesheet_name}.css - <a href="#"" onclick="#{commit_action}">commit</a> | <a href="#"" onclick="#{diff_action}">diff</a><br />}
        }
      end
      if status[:javascript]
        status[:javascript].each { |javascript_name|
          commit_action = %{Rb.request('/javascript-bundle-ext/project_window/commit?type=javascript&name=#{javascript_name}&project=#{@page.project.name}&page=#{@page.name}')}
          diff_action = %{Rb.request('/javascript-bundle-ext/project_window/commit?type=javascript&name=#{javascript_name}&project=#{@page.project.name}&page=#{@page.name}')}
          html += %{modified: #{javascript_name}.js - <a href="#"" onclick="#{commit_action}">commit</a> | <a href="#"" onclick="#{diff_action}">diff</a><br />}
        }
      end
      if status[:layout]
        layout_name = @page.resources.layout || "default"
        commit_action = %{Rb.request('/javascript-bundle-ext/project_window/commit?type=layout&name=#{layout_name}&project=#{@page.project.name}&page=#{@page.name}')}
        diff_action = %{Rb.request('/javascript-bundle-ext/project_window/commit?type=layout&name=#{layout_name}&project=#{@page.project.name}&page=#{@page.name}')}
        html += %{modified: #{layout_name}.layout - <a href="#"" onclick="#{commit_action}">commit</a> | <a href="#"" onclick="#{diff_action}">diff</a><br />}
      end
      # html += %{modified: #{@page.name}.erb - <a href="#"" onclick="#{commit_action}">commit</a>}
    else
      div[:class] = "green"
      commit = @page.project.git.last_commit
      html += "#{commit[:commit][0..5]} #{@page.name}.erb - <a href='#'>diff</a> - "
      # html += "changed #{distance_of_time_in_words commit[:date], Time.now, true} ago - #{commit[:author]}"
      html += "changed by #{commit[:author]} - #{commit[:date]}"
    end
    %{<div class="#{div[:class]}" style="position:absolute;right:0px;z-index:1000;border:#{div[:class]} 1px solid; padding:10px;background-color:#999" id="webmate_page_git_status">#{html}</div>}
  end
  
end
