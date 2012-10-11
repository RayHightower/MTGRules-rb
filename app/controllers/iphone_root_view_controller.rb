class IphoneRootViewController < UITableViewController
  extend IB

  attr_accessor :delegate, :contents

  def viewDidLoad
    view.dataSource = view.delegate = self
    self.title = "Rules"
  end


  def numberOfSectionsInTableView(table_view)
    1
  end


  def tableView(table_view, numberOfRowsInSection: section)
    contents.size
  end


  def tableView(table_view, cellForRowAtIndexPath: index_path)
    cell = table_view.dequeueReusableCellWithIdentifier("Cell")
    cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "Cell") if cell.nil?

    child = contents[index_path.row]
    cell.accessoryType = child.has_children? ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone
    cell.textLabel.text = child.text
    cell
  end


  def show_extra_info(key)
    text = delegate.database.get_extra_info(key)
    extras_controller = IphoneExtrasViewController.alloc.initWithNibName("ExtrasView", bundle: nil)
    extras_controller.set_extras_text(text)
    extras_controller.delegate = delegate
    extras_controller.title = key
    navigationController().pushViewController(extras_controller, animated: true)
  end


  def show_glossary
    glossary_controller = IphoneGlossaryViewController.alloc.initWithNibName("GlossaryView", bundle: nil)
    glossary_controller.glossary = delegate.database.get_glossary
    glossary_controller.delegate = delegate
    glossary_controller.title = "Glossary"
    navigationController().pushViewController(glossary_controller, animated: true)
  end


  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    child = contents.children[index_path.row]
    if child.has_children?
      subsection_menu_controller = IphoneSubSectionMenuController.alloc.initWithStyle(UITableViewStylePlain)
      subsection_menu_controller.contents = child
      subsection_menu_controller.delegate = delegate
      navigationController().pushViewController(subsection_menu_controller, animated: true)
    elsif index_path.row == 0
      show_extra_info("Intro")
    elsif index_path.row == contents.size - 3
      show_glossary
    elsif index_path.row == contents.size - 2
      show_extra_info("Credits")
    elsif index_path.row == contents.size - 1
      show_extra_info("Customer Service Information")
    end
  end


  def search(sender)
    search_controller = IphoneSearchController.alloc.initWithNibName("IphoneSearchController", bundle: nil)
    search_controller.delegate = delegate
    navigationController().pushViewController(search_controller, animated: true)
  end

  def didReceiveMemoryWarning
    super.didReceiveMemoryWarning
  end

end