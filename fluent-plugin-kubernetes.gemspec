# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-kubernetes"
  spec.version       = "0.3.1"
  spec.authors       = ["Jimmi Dyson"]
  spec.email         = ["jimmidyson@gmail.com"]
  spec.description   = %q{Output filter plugin to add Kubernetes metadata}
  spec.summary       = %q{Output filter plugin to add Kubernetes metadata}
  spec.homepage      = "https://github.com/fabric8io/fluent-plugin-kubernetes"
  spec.license       = "ASL2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 4.0"
  spec.add_development_dependency "copyright-header"
  spec.add_development_dependency "minitest-vcr"
  spec.add_development_dependency "webmock"
  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "docker-api"
end
