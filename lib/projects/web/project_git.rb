class WebProjectGit
  def initialize(project)
    @project = project
  end
  def last_commit
    log = `git log master -1`.split("\n")
    { 
      :commit => log[0].gsub("commit ",''),
      :author => log[1].gsub("Author: ",''),
      :date => log[2].gsub("Date:  ",''),
    }
  end
end