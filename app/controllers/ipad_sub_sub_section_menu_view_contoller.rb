class IpadSubSubSectionmenuViewController < UITableViewController
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
    contents.numberOfChildren
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cellIdentifier = "Cell"

    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
    if cell.nil?
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: cellIdentifier)
    end

    child = contents.childAtIndex(indexPath.row)
    cell.textLabel.text = child.text

    cell
  end


  def showRulesFor(entry)
    rules = delegate.getRulesForSubsection(entry.subsection, subsubsection: entry.subsubsection)
    detailViewController.detailItem = rules
    detailViewController.titleItem.title = "#{contents.text} - #{entry.text}"
  end


  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    child = contents.children[indexPath.row]
    self.showRulesFor(child)
  end


end
