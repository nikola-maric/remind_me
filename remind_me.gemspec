# encoding: utf-8
# frozen_string_literal: true
require_relative 'lib/remind_me/version'

Gem::Specification.new do |spec|
  spec.name          = 'remind_me'
  spec.version       = RemindMe::VERSION
  spec.authors       = ['Nikola Marić']
  spec.email         = ['nkl.maric@gmail.net']

  spec.summary       = 'Processor of REMIND_ME comments in the code, reminding us to revisit parts of code'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/nikola-maric/remind_me'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/nikola-maric/remind_me'
  spec.metadata['changelog_uri'] = 'https://github.com/nikola-maric/remind_me'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'parser', '~> 3.0.2.0'
end
