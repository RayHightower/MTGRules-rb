$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'
Bundler.require


Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MTGRules-rb'
  app.version = "2.0"
  app.device_family = [:iphone, :ipad]
  app.deployment_target = "4.3"
  app.interface_orientations = [:portrait, :landscape_left, :landscape_right, :portrait_upside_down]
  app.icons = ["Icon.png", "Icon-72.png", "Icon@2x.png"]
  app.info_plist['NSMainNibFile'] = 'MainWindow'
  app.files_dependencies 'app/app_delegate.rb' => 'app/controllers/root_view_controller.rb'

  app.pods do
    pod 'FMDB'
  end
end
