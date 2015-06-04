require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint'
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send('disable_class_parameter_defaults')

# Blacksmith
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
  puts "Blacksmith needed only to push to the Forge"
end

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = ["spec/**/*", "vendor/**/*", "pkg/**/*"]
  config.log_format = '%{path}:%{linenumber}:%{KIND}: %{message}'
  config.disable_checks = [ "disable_class_inherits_from_params_class", "disable_80chars" ]
end

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
]
