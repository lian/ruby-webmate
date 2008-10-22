require 'rubygems'
require "yaml"
require "erb"
require "json"

module Webmate
  @@projects_path ||= nil
  def self.init_projects_path(path)
    return true if File.exists?(path) && File.directory?(path)
    (Dir.mkdir(path) && File.exists?(path)) if !File.exists?(path) && File.exists?(File.dirname(path))
  end
  def self.projects_path(path=nil)
    @@projects_path = path if path && self.init_projects_path(path); return @@projects_path
  end
end

require File.dirname(__FILE__) + '/project.rb'
require File.dirname(__FILE__) + '/page.rb'
