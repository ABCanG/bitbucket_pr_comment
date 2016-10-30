# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitbucket_pr_commnet/version'

Gem::Specification.new do |spec|
  spec.name          = 'bitbucket_pr_commnet'
  spec.version       = BitbucketPrCommnet::VERSION
  spec.authors       = ['ABCanG']
  spec.email         = ['abcang1015@gmail.com']

  spec.summary       = 'post comment to pull requiest on bitbucket.'
  spec.description   = 'post comment to pull requiest on bitbucket.'
  spec.homepage      = 'https://github.com/ABCanG/bitbucket_pr_commnet'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
