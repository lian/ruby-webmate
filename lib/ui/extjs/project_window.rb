class ProjectTree
  def initialize(project, params={})
    @project = project
    @params = params
  end

  def delegate_menu_event(type,event)
    # types => :page, :stylesheet, :layout, javascript...
    case event
      when :edit
        JavascriptBundle::Ext::Handler.new %{ Rb.ext("project_window/edit?project=#{@project.name}&type=#{type}&name="+this.node.text); }
      when :new
        # JavascriptBundle::Ext::Handler.new %{ Rb.ext("project_window/new_page?project=#{@project.name}&#{type}="+this.node.text); }
        page_referer = @params[:page] ? "&page=#{@params[:page]}" : ""
        JavascriptBundle::Ext::Handler.new %{
          console.log(".. new #{type.to_s} dialog");
          Rb.ext("project_window/create_resource?project=#{@project.name}&resource_type=#{type.to_s}#{page_referer}")
        }
      when :git
        JavascriptBundle::Ext::Handler.new %{ Rb.ext("project_window/open_gitk?project=#{@project.name}") }
      when :deploy
        JavascriptBundle::Ext::Handler.new %{ Rb.ext("project_window/simple_deploy?project=#{@project.name}") }
      when :show
        if type == :page
          JavascriptBundle::Ext::Handler.new %{
            console.log("redirect to page: "+this.node.text)
            window.location.href = this.node.text;
          }
        end
    end
  end

  def menu_item(title,type,event=nil)
    { :text => title, :node => JavascriptBundle::Ext::Scope::This.new, :handler => delegate_menu_event(type, (event || title.downcase.to_sym)) }
  end

  def context_menu(type,scope=nil)
    # menu = JavascriptBundle::Ext::Menu::Menu.new( { :id => 'menuContext', :items => [ ] })
    menu = JavascriptBundle::Ext::Menu::Menu.new( { :items => [ ] })
    case type
      when :pages
        menu.items << menu_item("add", :page, :new)
        menu.items << menu_item("gitk", :page, :git)
        menu.items << menu_item("deploy", :page, :deploy)
      when :page
        menu.items << menu_item("show", :page)
        menu.items << menu_item("edit", :page)
        menu.items << "-"
        menu.items << menu_item("log", :page)
        # menu.items << { :text => 'show', :node => JavascriptBundle::Ext::Scope::This.new, :handler => delegate_menu_event(type, :show) }
      when :stylesheets
        menu.items << menu_item("add", :stylesheet, :new)
      when :stylesheet
        menu.items << menu_item("edit", :stylesheet)
      when :javascripts
        menu.items << menu_item("add", :javascript, :new)
      when :javascript
        menu.items << menu_item("edit", :javascript)
      when :layouts
        menu.items << menu_item("add", :layout, :new)
      when :layout
        menu.items << menu_item("edit", :layout)
    end
    JavascriptBundle::Ext::Handler.new(%{ var menu = #{menu.to_json}; menu.show(this.ui.getAnchor()); }) if menu.items.size > 0
  end


  def build_nodes(type,items,title=nil,expanded=false)
    parent_node = { :text => (title || type.to_s), :expanded => expanded, :children => [], :listeners => { :contextmenu => { :fn => context_menu("#{type.to_s}s".to_sym) } } }
    items.each { |item_name|
      parent_node[:children] << { 
        :text => item_name, :id => "#{type.to_s}-node-#{item_name}", :expanded => false, :children => [],
        :listeners => { :contextmenu => { :fn => context_menu(type, item_name) }, }
      }
    }
    parent_node
  end

  def build_page_resoures_nodes(page_name)
    page = WebPage.new(page_name, @project)
    nodes = []

    if page.resources.layout
      nodes << {
        :text => page.resources.layout, :id => "layout-node-#{page.resources.layout}", :expanded => false, :children => [],
        :listeners => { :contextmenu => { :fn => context_menu(:layout, page.resources.layout) } }
      }
    end

    # add javascript resources
    nodes += page.resources.javascripts.collect do |resource_name|
      resource_name = resource_name.to_s
      {
        :text => "#{resource_name}.js", :id => "javascript-node-#{resource_name}", :expanded => false, :children => [],
        :listeners => { :contextmenu => { :fn => context_menu(:javascript, resource_name) } }
      }
    end
    # add stylesheet resources
    nodes += page.resources.stylesheets.collect do |resource_name|
      resource_name = resource_name.to_s
      {
        :text => "#{resource_name}.css", :id => "stylesheet-node-#{resource_name}", :expanded => false, :children => [],
        :listeners => { :contextmenu => { :fn => context_menu(:stylesheet, resource_name) } }
      }
    end
    nodes
  end

  def build_page_nodes(type,items,title=nil,expanded=false)
    root_node = { :text => (title || type.to_s), :expanded => expanded, :children => [], :listeners => { :contextmenu => { :fn => context_menu("#{type.to_s}s".to_sym) } } }
    items.each { |page_name|
      expanded = (@params[:page] == page_name) ? true : false
      root_node[:children] << { 
        :text => page_name,
        :id => "#{type.to_s}-node-#{page_name}",
        :expanded => expanded,
        :selected => true,
        :children => build_page_resoures_nodes(page_name),
        :listeners => { :contextmenu => { :fn => context_menu(type, page_name) }, }
      }
    }
    root_node
  end
  
  def build_tree
    tree_root = { :text => "root", :expanded => true, :children => [] }
    #tree_root[:children] << build_nodes(:page, @project.pages, "html", true )
    tree_root[:children] << build_page_nodes(:page, @project.pages, "page", true )
    tree_root[:children] << build_nodes(:layout, @project.layouts, "layout", false )
    #tree_root[:children] << build_controller_nodes(:controller, @project.pages, "controller", true )
    tree_root[:children] << build_nodes(:stylesheet, @project.stylesheets, "css", false )
    tree_root[:children] << build_nodes(:javascript, @project.javascripts, "js", false )
    # tree_root[:children] << build_nodes(:layout, @project.layout_list, "layout" )
    tree_root
  end

  def init
    JavascriptBundle::Ext::Tree::TreePanel.new({
                               :id => 'project_tree',
                               #:region => 'west',
		                           :layout => 'fit',
                               #:height => 110, :minHeight => 110,
                               :width => 200, :minWidth => 150,
                               :loader => JavascriptBundle::Ext::Tree::TreeLoader.new({}),
                               :rootVisible => false,
                               :lines => false,
                               :autoScroll => true,
                               :root => JavascriptBundle::Ext::Tree::AsyncTreeNode.new( build_tree ),
                               # :resizeable => true
                               :tools => [
                                 { :id => "refresh",
                                   :on => { :click => JavascriptBundle::Ext::Handler.new(%{ console.log("refresh called..") }) }
                                 }
                               ]
                            })
  end
end


class ProjectWindow
  def initialize(current_project, params={} )
    @project = current_project
    @params = params
    # @ext_var = "sitemap_window_#{@project.meta["project_name"]}"
    @ext_var = "project_window"
  end

  def init_window
    # toolbar =  [ button_action_add,'-',button_action_open ]
    
    tree_panel =  ProjectTree.new(@project, @params).init
    main_window = JavascriptBundle::Ext::Window.new(
                                      #:tbar => toolbar,
                                      :layout => 'fit',
                                      :width => 200, :height => 300, :plain => true,
                                      :items => [ tree_panel ],
                                      #:items => [ { :html => "<b>hello</b>"} ],
                                      :title => @project.name,
                                      :closable => true, :closeAction => 'hide' )
                                      
    %{
      if (!#{@ext_var}) {
        var #{@ext_var} = #{main_window.to_json};
        #{@ext_var}.show(document.body);
      } else {
        #{@ext_var}.show(document.body);
      }
    }
  end


  ###
  ### controller methods
  ###
  def self.handle_init(params,scope)
    if Webmate.projects.include? params[:project]
      if project = WebProject.load(params[:project])
        new(project, params).init_window
      end
    end
  end
  
  def self.handle_reload_tree(params,scope)
    if Webmate.projects.include? params[:project]
      if project = WebProject.load(params[:project])
        tree_nodes = JavascriptBundle::Ext::Tree::AsyncTreeNode.new( ProjectTree.new(project, params).build_tree )
        %{
          var tree = project_window.items.items[0];
          tree.root.ui.remove();
          tree.setRootNode(#{tree_nodes.to_json});
          tree.root.render();
          tree.body.unmask();
          //tree.root.expand(true, false);
        }
      end
    end
  end
  
  def self.handle_edit(params,scope)
    if Webmate.projects.include? params[:project]
      if @project = WebProject.load(params[:project])
        
        type_map = {
          "page" => "erb",
          "javascript" => "js",
          "stylesheet" => "css",
          "layout" => "erb",
          "partial" => "erb",
        }

        if type_map.keys.include? params[:type]
          unless params[:name] == ""
            extname = type_map[params[:type]]
            params[:name] = "#{params[:name]}.#{extname}" unless params[:name].downcase.match(/.\.#{extname}$/)
            
            #file_path = "#{@project.path}/#{params[:type]}/#{params[:name]}.#{type_map[params[:type]]}"
            case params[:type]
            when "page"
              file_path = "#{@project.path}/pages/#{params[:name]}"
            when "layout"
              file_path = "#{@project.path}/pages/_layout/#{params[:name]}"
            when "stylesheet"
              file_path = "#{@project.path}/resources/css/#{params[:name]}"
            when "javascript"
              file_path = "#{@project.path}/resources/js/#{params[:name]}"
            else
              file_path = nil
            end

            if file_path && File.exists?(file_path)
              case params[:editor] 
                when "html"
                  "console.log('es gibt noch keinen html editor..')"
                else
                  system("mate '#{file_path}'") if File.file?(file_path)
                  "console.log('#{params[:name]} hat sich in textmate geöffnet und kann jetzt bearbeitet werden.')"
              end
            else
              puts "!!!!!not found: #{file_path} ==> #{params.inspect}"
              "console.log('#{params[:name]} wurde nicht gefunden. :(')"
            end
          end
        end
        
      end
    end
  end
  
  def self.handle_open_gitk(params,scope)
    if Webmate.projects.include? params[:project]
      if project = WebProject.load(params[:project])
        system "cd #{project.path}; gitk &" # project.git.open_gitk
        return %{ console.log("gitk: #{params[:project]} geöffnet") }
      end
    end
  end
  
  def self.handle_simple_deploy(params,scope) # fix ugly mess..
    if Webmate.projects.include? params[:project]
      if project = WebProject.load(params[:project])
        WebProjectDeploy.new(project).deploy!
        return %{ console.log("simple_deploy: #{params[:project]} angestoßen!") }
      end
    end
  end
  
  def self.handle_commit(params,scope)
    # params: project, name|resource_name, type|resource_type
    if Webmate.projects.include? params[:project]
      if params[:type] && project = WebProject.load(params[:project])
        if project.git.commit(params[:name],params[:type])
          redirect_to = params[:page]
          redirect_to = params[:name] if params[:type] == "page"
          return %{
            console.log("gesichert. ..weiterleitung/page-refresh")
            window.location.href = #{redirect_to.to_json};
          }
        else
          return %{ console.log("fehler beim sichern..") }
        end
      end
    end
  end

  #     show dialog: Rb.ext("project_window/create_resource?project=#{project.name}#{resource_type}")
  # create callback: Rb.ext("project_window/create_resource?project=#{project.name}#{resource_type}&resource_name="+resource_name)
  def self.handle_create_resource(params,scope)
    if Webmate.projects.include? params[:project]
      if project = WebProject.load(params[:project])
        
        if params[:resource_name] && (params[:resource_name] != "") && params[:resource_type]
          
          if project.resources.create(params[:resource_type], params[:resource_name])
            page_args = params[:page] ? "&page=#{params[:page]}" : ""
            return %{
              project_window.items.items[0].body.mask('reloading', 'x-mask-loading');
              Rb.ext("project_window/reload_tree?project=#{project.name}#{page_args}");
              console.log("#{project.name}: new #{params[:resource_type]}: #{params[:resource_name]}")
            }
          else
            return %{ console.log("#{project.name}: new #{params[:resource_type]}: #{params[:resource_name]} - ERROR") }
          end
          
        else
          if WebProjectResources::RESOURCES_SCHEME.keys.include? params[:resource_type].to_sym
            resource_type = "&resource_type=#{params[:resource_type]}"
            page_referer = params[:page] ? "&page=#{params[:page]}" : ""
            
            %{
              function handleDialog (button,resource_name){
                if ( button != "cancel") {
                  Rb.ext("project_window/create_resource?project=#{project.name}#{resource_type}#{page_referer}&resource_name="+resource_name)
                }
              };
              Ext.MessageBox.prompt('New #{params[:resource_type]} for #{project.name}', 'Please enter a name:', handleDialog );
            }
          else
            return %{ console.log("#{project.name}: create_resource #{params[:resource_type]} #{params[:resource_name]} - no #{params[:resource_type]} found ERROR") }
          end
        end
        
      end
    end
  end


  def self.handle_create_project(params,scope)
    if params[:name] && (params[:name] != "")
      
      if Webmate.create_project params[:name]
        redirect_to = "/project/#{params[:name]}/" # /index
        return %{ window.location.href = #{redirect_to.to_json} }
      else
        return %{ console.log("new project: #{params[:name]} error") }
      end
      
    else
      %{
        function handleNewProject (a,b){
          if (a != "cancel") {
            Rb.ext("project_window/create_project?name="+b)
          }
        };
        Ext.MessageBox.prompt('New Project', 'Please enter a name:', handleNewProject );
      }
    end
  end

end

JavascriptBundle::Ext::Backend::Widgets.add ProjectWindow, "project_window"
