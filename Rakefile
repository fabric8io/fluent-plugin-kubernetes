require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

task :headers do
  require 'rubygems'
  require 'copyright_header'

  args = {
    :license => 'ASL2',
    :copyright_software => 'Fluentd Kubernetes Output Plugin',
    :copyright_software_description => "Enrich Fluentd events with Kubernetes metadata",
    :copyright_holders => ['Red Hat, Inc.'],
    :copyright_years => ['2015'],
    :add_path => 'lib:test',
    :output_dir => '.'
  }

  command_line = CopyrightHeader::CommandLine.new( args )
  command_line.execute
end
