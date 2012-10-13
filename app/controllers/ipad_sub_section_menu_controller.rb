class IpadSubSectionMenuController < UITableViewController
  attr_accessor :delegate, :contents, :detail_view_controller


  def viewDidLoad
    super
    self.title = contents.text
  end


  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    true
  end


  def numberOfSectionsInTableView(table_view)
    1
  end


  def tableView(table_view, numberOfRowsInSection: section)
    contents.size
  end


  def tableView(table_view, cellForRowAtIndexPath: index_path)
    cell_identifier = "Cell"

    cell = tableView.dequeueReusableCellWithIdentifier(cell_identifier) ||  UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: cell_identifier)

    child = contents[index_path.row]
    cell.accessoryType = child.has_children? ? UITableViewCellAccessoryDisclosureIndicator : cell.accessoryType = UITableViewCellAccessoryNone
    cell.textLabel.text = child.text

    cell
  end


  def showRulesFor(entry)
    rules = delegate.database.get_rules_for_subsection(entry.subsection)
    @detail_view_controller.detail_item = rules
    @detail_view_controller.titleItem.title = "#{entry.text} - #{entry.text}"
  end


  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    child = contents[index_path.row]
    if child.has_children?
      subsubsection_menu_controller = IpadSubSubSectionMenuController.alloc.initWithStyle(UITableViewStylePlain)
      subsubsection_menu_controller.contents = child
      subsubsection_menu_controller.delegate = delegate
      subsubsection_menu_controller.detail_view_controller = @detail_view_controller
      navigationController.pushViewController(subsubsection_menu_controller, animated: true)
    else
      showRulesFor(child)
    end
  end


end
