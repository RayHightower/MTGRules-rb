class IphoneRootViewController < RootViewController
  extend IB


  def show_section(node)
    subsection_menu_controller = IphoneSubSectionMenuController.alloc.initWithStyle(UITableViewStylePlain)
    subsection_menu_controller.contents = node
    subsection_menu_controller.delegate = delegate
    navigationController.pushViewController(subsection_menu_controller, animated: true)
  end


  def show_extra_info(key)
    text = delegate.database.get_extra_info(key)
    extras_controller = IphoneExtrasViewController.alloc.initWithNibName("IphoneExtrasView", bundle: nil)
    extras_controller.set_extras_text(text)
    extras_controller.delegate = delegate
    extras_controller.title = key
    navigationController.pushViewController(extras_controller, animated: true)
  end


  def show_glossary
    glossary_controller = IphoneGlossaryViewController.alloc.initWithNibName("IphoneGlossaryView", bundle: nil)
    glossary_controller.glossary = delegate.database.get_glossary
    glossary_controller.delegate = delegate
    glossary_controller.title = "Glossary"
    navigationController.pushViewController(glossary_controller, animated: true)
  end


  def search(sender)
    search_controller = IphoneSearchController.alloc.initWithNibName("IphoneSearchView", bundle: nil)
    search_controller.delegate = delegate
    navigationController.pushViewController(search_controller, animated: true)
  end


end
