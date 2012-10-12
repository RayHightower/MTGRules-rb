class IpadSubSectionMenuController < UITableViewController

  attr_accessor :delegate, :contents, :detailViewController


  def viewDidLoad
    super
    self.title = contents.text
  end


  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end


  def numberOfSectionsInTableView(tableView)
    1
  end


  def tableView(tableView, numberOfRowsInSection: section)
    contents.size
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cellIdentifier = "Cell"

    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) ||  UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: cellIdentifier)

    child = contents[indexPath.row]
    cell.accessoryType = child.has_children? ? UITableViewCellAccessoryDisclosureIndicator : cell.accessoryType = UITableViewCellAccessoryNone
    cell.textLabel.text = child.text

    cell
  end


  def showRulesFor(entry)
    rules = delegate.database.get_rules_for_subsection(entry.subsection)
    detailViewController.detail_item = rules
    detailViewController.titleItem.title = "#{entry.text} - #{entry.text}"
  end


  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    child = contents[indexPath.row]
    if child.has_children?
      subsubsectionMenuController = IpadSubSubSectionMenuController.alloc.initWithStyle(UITableViewStylePlain)
      subsubsectionMenuController.contents = child
      subsubsectionMenuController.delegate = delegate
      subsubsectionMenuController.detailViewController = detailViewController
      navigationController.pushViewController(subsubsectionMenuController, animated: true)
    else
      showRulesFor(child)
    end
  end


end
