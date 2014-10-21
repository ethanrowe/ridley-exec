$:.push File.expand_path('../lib', __FILE__)
require 'ridley-exec/version'

Gem::Specification.new do |s|
  s.name      = 'ridley-exec'
  s.version    = RidleyExec::VERSION
  s.authors    = ['Ethan Rowe']
  s.email      = ['ethanrowe000@gmail.com']
  s.homepage  = 'https://github.com/ethanrowe/ridley-exec'
  s.summary    = 'Basic utility for executing ruby scripts with ridley chef API in scope'
  s.description  = s.summary

  s.add_dependency 'ridley', '>= 4.0'
  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end

