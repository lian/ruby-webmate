require 'rake'

desc 'run specs'
task(:spec) { sh 'ruby spec/*.rb' }
task :default => :spec

namespace :spec do
  desc 'run all specs'
  task :all => [:webmate, :project]
  
  desc 'run webmate specs'
  task(:webmate) { sh 'ruby spec/webmate_spec.rb' }
  
  desc 'run webmate.project specs'
  task(:project) { sh 'ruby spec/project_spec.rb' }
  
  desc 'run webmate.project.page specs'
  task(:page) { sh 'ruby spec/page_spec.rb' }
end
