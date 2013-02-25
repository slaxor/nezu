# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "nezu"
  s.version     = File.read(File.join(File.dirname(__FILE__), 'VERSION'))
  s.authors     = ["Sascha Teske"]
  s.email       = %q{sascha.teske@gmail.com}
  s.homepage    = %q{http://github.com/slaxor/nezu}
  s.summary     = %q{Skel generator and launcher for amqp consumers}
  s.description = %q{Skel generator and launcher for amqp consumers.}

  s.add_dependency             'amqp'
  s.add_dependency             'bunny', '>= 0.9.0.pre6'
  s.add_dependency             'activerecord', '~>3.2.11'
  s.add_dependency             'activesupport', '~>3.2.11'
  s.add_dependency             'configatron'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sdoc'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'debugger'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
