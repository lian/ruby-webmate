require File.dirname(__FILE__) + '/resources_helper.rb'

class RenderEngineResources
  def initialize(scope)
    @resources = { :javascript => [], :stylesheet => [], :layout => nil }
    @scope = scope
    @page = @scope.page
    @project = @page.project
  end

  def render_page_content;@scope.render_page;end
  def render_content;render_page_content;end
  def render_layout;@scope.render_layout;end
  def render_page_with_layout;render_layout;end
    
  include PageResourcesHelper
  include HTMLResourcesHelper
  
  def get_binding;binding;end
  def inspect;@resources.inspect;end
end


class PageResources
  attr_accessor :resources
  def initialize
    @resources = { :javascript => [], :stylesheet => [], :layout => nil }
  end
  
  include PageResourcesHelper
  
  def get_binding;binding;end
  def inspect;@resources.inspect;end
end
