require "jeweler"
require "rcov/rcovtask"
require "rake/testtask"
require "rake/rdoctask"
require "lib/activities/version"

Rcov::RcovTask.new do |t|
  t.test_files = FileList["test/**/*_test.rb"]
  t.rcov_opts = ["--sort coverage", "--exclude .gem,.bundle,errors.rb"]

  t.output_dir = "coverage"
  t.libs << "test"
  t.verbose = true
end

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

Rake::RDocTask.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "doc"
  rdoc.title = "Actitivies API"
  rdoc.options += %w[ --line-numbers --inline-source --charset utf-8 ]
  rdoc.rdoc_files.include("README.rdoc")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

JEWEL = Jeweler::Tasks.new do |gem|
  gem.name = "activities"
  gem.email = "fnando.vieira@gmail.com"
  gem.homepage = "http://github.com/fnando/activities"
  gem.authors = ["Nando Vieira"]
  gem.version = Activities::Version::STRING
  gem.summary = "A framework for aggregating social activity."
  gem.files =  FileList["{README,CHANGELOG}.rdoc", "{lib,test}/**/*", "Rakefile"]
end

Jeweler::GemcutterTasks.new
