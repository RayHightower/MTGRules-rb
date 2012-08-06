class AppDelegate
  extend IB

  attr_accessor :top_level_contents

  attr_accessor :window
  attr_accessor :navigation_controller
  attr_accessor :root_view_controller

  ib_outlet :window, UIWindow
  ib_outlet :navigation_controller, UINavigationController
  ib_outlet :root_view_controller


  def application(application, didFinishLaunchingWithOptions:launchOptions)
    return true if RUBYMOTION_ENV == 'test'
    @database = Database.new("rules.dat")
    @top_level_contents = @database.load_contents

    @root_view_controller = RootViewController.alloc.initWithNibName("RootView", bundle: nil)
    @root_view_controller.delegate = self
    @root_view_controller.contents = top_level_contents

    @navigation_controller = UINavigationController.alloc.initWithRootViewController(root_view_controller)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @navigation_controller
    @window.makeKeyAndVisible
    true
  end


  def get_extra_info(key)
    @database.get_extra_info(key)
  end


  def get_glossary
    @database.get_glossary
  end


  def get_rules_for_subsection(subsection)
    @database.get_rules_for_subsection(subsection)
  end


  def get_rules_for_subsection(subsection, and_subsubsection: subsubsection_root)
    @database.get_rules_for_subsection(subsection, and_subsubsection: subsubsection_root)
  end


  def get_rules_referenced_by_glossary_term(term)
    @database.get_rules_referenced_by_glossary_term(term)
  end


  def get_rules_referenced_by_rule(clause)
    @database.get_rules_referenced_by_rule(clause)
  end


  def search_for(fragment)
    @database.search_for(fragment)
  end


  def search(sender)
    root_view_controller.search(sender)
  end

  ib_action :search

end
