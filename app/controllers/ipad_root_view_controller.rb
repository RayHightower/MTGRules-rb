class IpadRootViewController < RootViewController
  extend IB

  outlet :detailViewController, IpadDetailViewController


  def viewDidLoad
    super
    detailViewController.delegate = delegate
    show_extra_info("Intro")
  end
  

  def show_section(node)
    subsection_menu_controller = IpadSubSectionMenuController.alloc.initWithStyle(UITableViewStylePlain)
    subsection_menu_controller.contents = node
    subsection_menu_controller.detailViewController = detailViewController
    subsection_menu_controller.delegate = delegate
    navigationController.pushViewController(subsection_menu_controller, animated: true)
  end


  def show_extra_info(key)
    detailViewController.detail_item = delegate.database.get_extra_info(key)
    detailViewController.titleItem.title = key
  end


  def show_glossary
    detailViewController.detail_item = delegate.database.get_glossary
    glossary_controller.title = "Glossary"
  end


  def search(sender)
    detailViewController.search(sender)
  end


end
