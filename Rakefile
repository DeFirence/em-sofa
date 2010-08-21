require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  require 'lib/em-sofa/version'
  Jeweler::Tasks.new do |gem|
    gem.name = "em-sofa"
    gem.version = EventMachine::Sofa::Version::STRING
    gem.summary = %Q{An EventMachine based Ruby library for the TVRage API.}
    gem.description = %Q{A simple EventMachine based Ruby library for the TVRage API.}
    gem.email = "defirence@defirence.za.net"
    gem.homepage = "http://github.com/DeFirence/em-sofa"
    gem.authors = ["DeFirence", "Henry Hsu"]
    gem.add_dependency "em-http-request"
    gem.add_dependency "crack"
    gem.add_development_dependency "fakeweb"
    gem.add_development_dependency "mocha"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = %w{--exclude spec/*,gems/*}
end

task :spec => :check_dependencies

begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
