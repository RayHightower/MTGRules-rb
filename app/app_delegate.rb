class AppDelegate
  extend IB

  attr_accessor :top_level_contents

  attr_accessor :window
  attr_accessor :navigationController
  attr_accessor :rootViewController

  ib_outlet :window, UIWindow
  ib_outlet :navigationController, UINavigationController
  ib_outlet :rootViewController


  def application(application, didFinishLaunchingWithOptions:launchOptions)
    return true if RUBYMOTION_ENV == 'test'
    @database = Database.new("rules.dat")
    @top_level_contents = @database.load_contents

    @rootViewController.delegate = self
    @rootViewController.contents = top_level_contents

#    @navigationController = UINavigationController.alloc.initWithRootViewController(rootViewController)

#    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.addSubview(@navigationController.view)
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
    rootViewController.search(sender)
  end

  ib_action :search

end
