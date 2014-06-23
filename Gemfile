source 'https://rubygems.org'
gemspec
group :development, :test do
  case RUBY_VERSION.match(/^([12])/)[1]
  when "1"
    gem 'debugger'
  when "2"
    gem 'byebug'
  end
end

