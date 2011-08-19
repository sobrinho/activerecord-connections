Gem::Specification.new do |s|
  s.name        = "activerecord-connections"
  s.version     = "0.0.1"
  s.authors     = ["Gabriel Sobrinho"]
  s.email       = ["gabriel.sobrinho@gmail.com"]
  s.homepage    = "https://github.com/sobrinho/activerecord-connections"
  s.summary     = %q{ActiveRecord with multiple databases}
  s.description = %q{ActiveRecord with multiple databases}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '>= 3.0'
  s.add_dependency 'activerecord', '>= 3.0'
  s.add_development_dependency 'rake', '>= 0.8.7'
end
