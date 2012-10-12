$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'
Bundler.require


Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MTGRules-rb'
  app.device_family = [:iphone, :ipad]
  app.deployment_target = "4.3"
  app.interface_orientations = [:portrait]
  app.info_plist['NSMainNibFile'] = 'MainWindow'
  app.files_dependencies 'app/app_delegate.rb' => 'app/controllers/root_view_controller.rb'

  app.pods do
    pod 'FMDB'
  end
end
