lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'train-pcp/version'

Gem::Specification.new do |spec|
  spec.name          = 'train-pcp'

  spec.version       = TrainPlugins::PCP::VERSION
  spec.authors       = ['Sean Millichamp']
  spec.email         = ['sean@bruenor.org']
  spec.summary       = 'Train Plugin for the Puppet Enterprise PCP transport.'
  spec.description   = 'This implements a Puppet Enterprise PCP transport for Train.'
  spec.homepage      = 'https://github.com/seanmil/train-pcp'
  spec.license       = 'Apache-2.0'

  # Though complicated-looking, this is pretty standard for a gemspec.
  # It just filters what will actually be packaged in the gem (leaving
  # out tests, etc)
  spec.files = %w{
    README.md train-pcp.gemspec Gemfile
  } + Dir.glob(
    'lib/**/*', File::FNM_DOTMATCH
  ).reject { |f| File.directory?(f) }
  spec.require_paths = ['lib']

  # All plugins should mention train, > 1.4
  spec.add_dependency 'train', '~> 1.4'
  spec.add_dependency 'orchestrator_client'
end
