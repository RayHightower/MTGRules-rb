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
    @rules.count
  end


  def getCellTextAtIndexPath(indexPath)
    @rules[indexPath.row].text
  end


  def bodyHeightFor(text)
    cellFont = UIFont.fontWithName("Helvetica", size: 18.0)
    constraintSize = CGSizeMake(602, Float::MAX)
    labelSize = text.sizeWithFont(cellFont, constrainedToSize: constraintSize, lineBreakMode: UILineBreakModeWordWrap)
    labelSize.height
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cellIdentifier = "IpadDetailCell"

    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
    if cell.nil?
      NSBundle.mainBundle.loadNibNamed(cellIdentifier, owner: self, options: nil)
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
    bodyLabel.font = UIFont.fontWithName("Helvetica", size: 18.0)
    bodyFrame = bodyLabel.frame
    bodyFrame.size.height = bodyHeightFor(clause.body)
    bodyLabel.frame = bodyFrame
    cell
  end


  def heightForRow(row)
    bodyHeightFor(@rules[row].body) + 54
  end


  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    heightForRow(indexPath.row)
  end


  def tableViewHeight
    (0...@rules.count).inject(0.0) {|height, i| height + heightForRow(i) }
  end


  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    clause = @rules[indexPath.row]
    moreRules = delegate.database.get_rules_referenced_by_rule(clause)

    if moreRules.count > 0
      popOverRules = IpadRulePopOverTableViewController.alloc.init
      popOverRules.rules = moreRules
      popOverRules.delegate = delegate
      f = view.frame
      popOverRules.view.frame = f

      @popOver = UIPopoverController.alloc.initWithContentViewController(popOverRules)
      @popOver.delegate = self
      @popOver.popoverContentSize = f.size
      selectedCell = tableView.cellForRowAtIndexPath(indexPath)

      @popOver.presentPopoverFromRect(selectedCell.frame, inView: tableView, permittedArrowDirections: UIPopoverArrowDirectionAny, animated: true)
    end
  end


  def popoverControllerDidDismissPopover(popoverController)
    view.deselectRowAtIndexPath(view.indexPathForSelectedRow, animated: true)
  end


end