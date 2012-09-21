Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'credit_card_support'
  s.version     = '1.0.0'
  s.summary     = 'Libary to handle CreditCard number, expiration and Luhn.'
  s.description = 'Detects issuer from number, has ActiveModel validations and translations support.'

  s.required_ruby_version = '>= 1.9.3'

  s.author            = 'Margus Pärt'
  s.email             = 'margus@tione.eu'
  s.homepage          = 'https://github.com/tione/credit_card_support'

  s.files        = Dir['Gemfile', 'README.md', 'LICENSE.txt', 'lib/**/*', 'spec/**/*']
  s.require_path = 'lib'
end

