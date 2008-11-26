# -*- ruby -*-

require 'rubygems'
require 'hoe'
$LOAD_PATH.unshift 'lib'
require 'blackbook'

begin
  require 'rcov/rcovtask'
rescue LoadError
end

Hoe.new('blackbook', Blackbook::VERSION) do |p|
  p.rubyforge_name = 'contentfree'
  p.author         = 'Contentfree'
  p.email          = 'dave.myron@contentfree.com'
  p.summary        = 'Blackbook handles the nitty-gritty of importing contacts from various service providers and contact lists and exporting them in a useful format.'
  p.description    = p.paragraphs_of('README.txt', 1).join("\n\n")
  p.url            = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes        = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps    << [ "mechanize", ">= 0.7.0" ]
  p.extra_deps    << [ "fastercsv", ">= 1.2.0" ]
  p.clean_globs << 'coverage'
  p.clean_globs << 'pkg'
  p.clean_globs << 'doc'
  p.clean_globs << 'ri'
end

task :release_and_publish => [:release, :publish_docs]

begin
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/test*.rb']
    t.verbose = true
    #t.rcov_opts << "--exclude rcov.rb,hpricot.rb,hpricot/.*\.rb"
  end
rescue NameError
end
