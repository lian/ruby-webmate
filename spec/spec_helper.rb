require 'rubygems'
require 'yaml'
require 'spec'

"--colour --format specdoc".split(" ").collect { |arg| ARGV << arg }
def remove_rspec_dir(dir_path); FileUtils.remove_dir(dir_path) if File.exists?(dir_path); end

require File.dirname(__FILE__) + '/../lib/webmate.rb'
Webmate.projects_path $projects_path = "/tmp/ruby-webmate" # use /tmp while testing
