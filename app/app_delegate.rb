class AppDelegate
  attr_accessor :window
  attr_accessor :top_level_contents
  attr_accessor :navigation_controller
  attr_accessor :root_view_controller
  
  def make_root_view_controller
  end
  
  def make_window
  end
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    return true if RUBYMOTION_ENV == 'test'
    @database = Database.new("rules.dat")
    # @top_level_contents = database.load_contents
    
    @root_view_controller = RootViewController.alloc.initWithStyle(UITableViewStylePlain)
    @root_view_controller.delegate = self
    # @root_view_controller.contents = top_level_contents
    
    @navigation_controller = UINavigationController.alloc.initWithRootViewController(root_view_controller)
    
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @navigation_controller
    @window.makeKeyAndVisible
    true
  end
end
