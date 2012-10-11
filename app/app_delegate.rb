class AppDelegate < NSObject
  extend IB

  attr_accessor :top_level_contents
  attr_reader :database

  outlet :window, UIWindow
  outlet :navigationController, UINavigationController
  outlet :rootViewController, IphoneRootViewController


  def application(application, didFinishLaunchingWithOptions: launchOptions)
    return true if RUBYMOTION_ENV == 'test'
    @database = Database.new("rules.dat")
    @top_level_contents = @database.load_contents

    rootViewController.delegate = self
    rootViewController.contents = @top_level_contents
    window.addSubview(navigationController.view)

    # window.addSubview(splitViewController.view)

    window.makeKeyAndVisible
    true
  end


  def search(sender)
    rootViewController.search(sender)
  end

  ib_action :search

end
