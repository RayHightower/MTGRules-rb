class IpadSubSubSectionMenuController < UITableViewController
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

    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
    if cell.nil?
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: cellIdentifier)
    end

    child = contents[indexPath.row]
    cell.textLabel.text = child.text

    cell
  end


  def showRulesFor(entry)
    rules = delegate.database.get_rules_for_subsection(entry.subsection, and_subsubsection: entry.subsubsection)
    detailViewController.detail_item = rules
    detailViewController.titleItem.title = "#{contents.text} - #{entry.text}"
  end


  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    child = contents[indexPath.row]
    self.showRulesFor(child)
  end


end
