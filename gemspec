Gem::Specification.new do |s|
    s.name          = 'xlg'
    s.version       = '0.4.2'
    s.authors       = ['Kazto TAKAHASHI']
    s.email         = ['kazto@kazto.dev']
    s.summary       = 'A Ruby library for reading and writing Excel files.'
    s.description   = '`xlg` is a command-line tool that provides functionality to search keywords in Excel files in various formats.'
    s.homepage      = 'https://github.com/kazto/xlg'
    s.license       = 'MIT'

    s.files         = Dir['lib/**/*', 'bin/xlg', 'README.md', 'LICENSE']
    s.require_paths = ['lib']
    s.required_ruby_version = '>= 3.0'
    s.add_dependency 'rubyXL', '~> 3.4'
    s.executables = ['xlg']
end
