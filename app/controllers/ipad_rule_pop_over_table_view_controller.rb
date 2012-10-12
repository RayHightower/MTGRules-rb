class IpadRulePopOverTableViewController < UITableViewController
  extend IB
  
  attr_accessor :delegate, :rules

  outlet :tableCell, UITableViewCell


  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end


  def didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    view.reloadData
  end


  def numberOfSectionsInTableView(tableView)
    1
  end


  def tableView(tableView, numberOfRowsInSection: section)
    rules.count
  end


  def getCellTextAtIndexPath(indexPath)
    rules[indexPath.row].text
  end


  def bodyHeightFor(text)
    cellFont = UIFont.fontWithName("Helvetica", size: 14.0)
    constraintSize = CGSizeMake(602, MAXFLOAT)
    labelSize = text.sizeWithFont(cellFont, constrainedToSize: constraintSize, lineBreakMode: UILineBreakModeWordWrap)
    labelSize.height
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cellIdentifier = "IpadDetailCell"

    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
    if cell.nil?
      NSBundle.mainBundle.loadNibNamed(CellIdentifier, owner: self, options: nil)
      cell = tableCell
      tableCell = nil
    end

    headerLabel =  cell.viewWithTag(1)
    bodyLabel = cell.viewWithTag(2)

    clause = rules[indexPath.row]
    headerLabel.text = "#{clause.subsection}.#{clause.subsubsection}"
    bodyLabel.text = clause.body

    bodyLabel.lineBreakMode = UILineBreakModeWordWrap
    bodyLabel.numberOfLines = 0
    bodyLabel.font = UIFont.fontWithName("Helvetica", size: 14.0)
    bodyFrame = bodyLabel.frame
    bodyFrame.size.height = bodyHeightFor(bodyLabel.body)
    bodyLabel.frame = bodyFrame
    cell
  end


  def heightForRow(row)
    bodyHeightFor(rules[row].body) + 54
  end


  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    heightForRow(indexPath.row)
  end


  def tableViewHeight
    (1...rules.count).inject(0.0) {|i| height += heightForRow(i) }
  end


  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    clause = rules[indexPath.row]
    moreRules = delegate.getRulesReferencedByRule(clause)

    if moreRules.count > 0
      popOverRules = IPadRulePopOverTableViewController.alloc.init
      popOverRules.rules = moreRules
      popOverRules.delegate = delegate
      f = view.frame
      popOverRules.view.frame = f

      popOver = UIPopoverController.alloc.initWithContentViewController(popOverRules)
      popOver.delegate = self
      popOver.popoverContentSize = f.size
      selectedCell = tableView.cellForRowAtIndexPath(indexPath)

      popOver.presentPopoverFromRect(selectedCell.frame, inView: tableView, permittedArrowDirections: UIPopoverArrowDirectionAny, animated: true)
    end
  end


  def popoverControllerDidDismissPopover(popoverController)
    view.deselectRowAtIndexPath(view.indexPathForSelectedRow, animated: true)
  end


end