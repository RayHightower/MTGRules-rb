$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'
Bundler.require


Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MTGRules-rb'
  app.device_family = :iphone
  app.interface_orientations = [:portrait]
  app.files_dependencies 'app/database.rb' => 'app/sqlite.rb'
  app.pods do
    dependency 'FMDB'
  end
end
