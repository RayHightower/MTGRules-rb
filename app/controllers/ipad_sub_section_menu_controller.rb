class IpadSubSectionmenuController < UITableViewController

  attr_accessor :delegate, :contents, :detailViewController


  def viewDidLoad
    super
    self.title = contents.name
  end


  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end


  def numberOfSectionsInTableView(tableView)
    1
  end


  def tableView(tableView, numberOfRowsInSection: section)
    contents.numberOfChildren
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cellIdentifier = "Cell"

    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) ||  UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: cellIdentifier)

    child = contents.childAtIndex(indexPath.row)
    if child.has_children?
      cell.accessoryType = child.has_children? ? UITableViewCellAccessoryDisclosureIndicator : cell.accessoryType = UITableViewCellAccessoryNone
      cell.textLabel.text = child.body
    end

    cell
  end


  def showRulesFor(entry)
    rules = delegate.getRulesForSubsection(entry.subsection)
    detailViewController.detailItem = rules
    detailViewController.titleItem.title = "#{content.text} - #{entry.text}"
  end


  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    child = contents.children[indexPath.row]
    if child.has_children?
      subsubsectionMenuController = IPadSubSubSectionMenuController.alloc.initWithStyle(UITableViewStylePlain)
      subsubsectionMenuController.contents = child
      subsubsectionMenuController.delegate = delegate
      subsubsectionMenuController.detailViewController = detailViewController
      navigationController(pushViewController: subsubsectionMenuController, animated: true)
    else
      showRulesFor(child)
    end
  end


end