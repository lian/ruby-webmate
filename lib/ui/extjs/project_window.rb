class ProjectTree
  def initialize(project)
    @project = project
  end

  def page_on(type)
    case type
      when :new
        JavascriptBundle::Ext::Handler.new %{ console.log("implement add page dialog") }
      when :show
        JavascriptBundle::Ext::Handler.new %{ Rb.ext("project_window/edit?project=#{@project.name}&page="+this.node.text); }
      when :edit
        JavascriptBundle::Ext::Handler.new %{ Rb.ext("project_window/edit?project=#{@project.name}&page="+this.node.text); }
      else
        JavascriptBundle::Ext::Handler.new %{ console.log("callback #{type} für "+this.node.text+" nicht gefunden..") }
    end
  end

  def delegate_menu_event(type,event)
    # types => :page, :stylesheet, :layout, javascript...
    case event
      when :edit
        JavascriptBundle::Ext::Handler.new %{ Rb.ext("project_window/edit?project=#{@project.name}&type=#{type}&name="+this.node.text); }
      when :new
        # JavascriptBundle::Ext::Handler.new %{ Rb.ext("project_window/new_page?project=#{@project.name}&#{type}="+this.node.text); }
        JavascriptBundle::Ext::Handler.new %{ console.log("implement add page dialog") }
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
  
  def build_tree
    tree_root = { :text => "root", :expanded => true, :children => [] }
    tree_root[:children] << build_nodes(:page, @project.pages, "html", true )
    tree_root[:children] << build_nodes(:stylesheet, @project.stylesheets, "css", true )
    tree_root[:children] << build_nodes(:javascript, @project.javascripts, "js", true )
    # tree_root[:children] << build_nodes(:layout, @project.layout_list, "layout" )
    tree_root
  end

  def init
    JavascriptBundle::Ext::Tree::TreePanel.new({
                               #:region => 'west',
		                           :layout => 'fit',
                               #:height => 110, :minHeight => 110,
                               :width => 200, :minWidth => 150,
                               :id => 'tree', 
                               :loader => JavascriptBundle::Ext::Tree::TreeLoader.new({}),
                               :rootVisible => false,
                               :lines => false,
                               :autoScroll => true,
                               :root => JavascriptBundle::Ext::Tree::AsyncTreeNode.new( build_tree ),
                               # :resizeable => true
                            })
  end
end


class ProjectWindow
  def initialize(current_project)
    @project = current_project
    # @ext_var = "sitemap_window_#{@project.meta["project_name"]}"
    @ext_var = "project_window"
  end

  def init_window
    # toolbar =  [ button_action_add,'-',button_action_open ]
    
    tree_panel =  ProjectTree.new(@project).init
    main_window = JavascriptBundle::Ext::Window.new(
                                      #:tbar => toolbar,
                                      :layout => 'fit',
                                      :width => 200, :height => 300, :plain => true,
                                      :items => [ tree_panel ],
                                      #:items => [ { :html => "<b>hello</b>"} ],
                                      :title => "Project Window",
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
        new(project).init_window
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
            #file_path = "#{@project.path}/#{params[:type]}/#{params[:name]}.#{type_map[params[:type]]}"
            case params[:type]
            when "page"
              file_path = "#{@project.path}/pages/#{params[:name]}.#{type_map[params[:type]]}"
            when "stylesheet"
              file_path = "#{@project.path}/resources/css/#{params[:name]}.#{type_map[params[:type]]}"
            when "javascript"
              file_path = "#{@project.path}/resources/js/#{params[:name]}.#{type_map[params[:type]]}"
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
              "console.log('#{params[:name]} wurde nicht gefunden. :(')"
            end
          end
        end
        
      end
    end
  end
  
  # def self.handle_edit(params,scope)
  #   current_project = scope
  #   if page_name = params[:page]
  #     page_fs_path = "#{current_project.path}/page/#{page_name}.erb"
  #     if File.exists?(page_fs_path)
  #       case params[:edit_type] 
  #         when "html"
  #           "console.log('es gibt noch keinen html editor..')"
  #         else
  #           system("mate '#{page_fs_path}'") if File.file?(page_fs_path)
  #           "console.log('#{page_name} hat sich in textmate geöffnet und kann jetzt bearbeitet werden.')"
  #       end
  #     else
  #       "console.log('#{page_name} wurde nicht gefunden.')"
  #     end
  #   end
  #   
  #   if css_name = params[:css]
  #     css_fs_path = "#{current_project.path}/stylesheet/#{css_name}.css"
  #     if File.exists?(css_fs_path)
  #       case params[:edit_type] 
  #         when "html"
  #           "console.log('es gibt noch keinen html editor..')"
  #         else
  #           system("mate '#{css_fs_path}'") if File.file?(css_fs_path)
  #           "console.log('#{css_name} hat sich in textmate geöffnet und kann jetzt bearbeitet werden.')"
  #       end
  #     else
  #       "console.log('#{css_name} wurde nicht gefunden.')"
  #     end
  #   end
  #   
  # end
  

end

JavascriptBundle::Ext::Backend::Widgets.add ProjectWindow, "project_window"
