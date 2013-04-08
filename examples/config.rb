###
# Compass
###

# Susy grids in Compass
# First: gem install susy
# require 'susy'

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Build-specific configuration
configure :build do

end

after_configuration do
  current_path = File.expand_path(File.dirname(__FILE__))
  sprockets.append_path File.join(current_path, '..', '..', 'lib')
  sprockets.append_path File.join(current_path, '..', '..', 'test', 'vendor')
  sprockets.append_path File.join(current_path, '..', '..', 'test', 'vendor', 'spine')
end