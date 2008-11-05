class WebProjectResources
  attr_reader :scheme
  def initialize(project)
    @project = project
    @scheme = {
      :page => %w{pages .erb <!-- -->},
      :layout => %w{pages/_layout .erb <!-- -->},
      :stylesheet => %w{resources/css .css /* */},
      :javascript => %w{resources/js .js // //},
    }
  end
  
  def get(resource_type, name=nil)
    return nil if !@scheme[type]
    Dir[@project.path+"/#{@scheme[type][0]}/*#{@scheme[type][1]}"].collect { |i|
      File.basename(i).gsub(@scheme[type][1],'')
    }
  end
  
  def file_list(resource_scheme)
    Dir[@project.path+"/#{resource_scheme[0]}/*#{resource_scheme[1]}"].collect { |i| File.basename(i).gsub(resource_scheme[1],'') }
  end

  def create(resource_type,name); create_resource(resource_type, name); end
  def create_page(name); create_resource(:page, name); end
  def create_javascript(name); create_resource(:javascript, name); end
  def create_stylesheet(name); create_resource(:stylesheet, name); end
  def create_layout(name); create_resource(:layout, name); end
  def create_resource(type,name)
    if scheme = @scheme[type.to_sym]
      return nil if file_list(scheme).include?(name)
      file_path = "#{scheme[0]}/#{name}#{scheme[1]}"

      old_path = Dir.pwd; Dir.chdir @project.path
      File.open(file_path,"wb") { |f| f.print "#{scheme[2]} #{type.to_s}: #{name} #{scheme[3]}" }
      Dir.chdir(old_path);true

      commit_files( file_path, "new #{type.to_s}: #{name}" )
    end
  end

  def commit_files(files,commit_msg)
    old_path = Dir.pwd; Dir.chdir @project.path
    case files
      when String
        system("git add \"#{files}\" > /dev/null 2>&1") if File.exists?("#{Dir.pwd}/#{files}")
      when Array
        files.each { |file_path| system("git add \"#{file_path}\" > /dev/null 2>&1") if File.exists?("#{Dir.pwd}/#{file_path}") }
    end
    system "git commit -m '#{commit_msg}' > /dev/null 2>&1"
    Dir.chdir(old_path);true
  end
end