class AppDelegate
  extend IB

  attr_accessor :top_level_contents

  attr_accessor :window
  attr_accessor :navigationController
  attr_accessor :rootViewController

  attr_reader :database

  ib_outlet :window, UIWindow
  ib_outlet :navigationController, UINavigationController
  ib_outlet :rootViewController, IphoneRootViewController


  def application(application, didFinishLaunchingWithOptions: launchOptions)
    return true if RUBYMOTION_ENV == 'test'
    @database = Database.new("rules.dat")
    @top_level_contents = @database.load_contents

    @rootViewController.delegate = self
    @rootViewController.contents = top_level_contents
    @window.addSubview(@navigationController.view)

    # @window.addSubview(splitViewController.view)

    @window.makeKeyAndVisible
    true
  end


  def search(sender)
    rootViewController.search(sender)
  end

  ib_action :search

end
