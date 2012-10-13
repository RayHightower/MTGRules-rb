class IpadRulePopOverTableViewController < UITableViewController
  extend IB
  
  attr_accessor :delegate, :rules

  outlet :tableCell, UITableViewCell


  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    true
  end


  def didRotateFromInterfaceOrientation(from_interface_orientation)
    view.reloadData
  end


  def numberOfSectionsInTableView(table_view)
    1
  end


  def tableView(table_view, numberOfRowsInSection: section)
    @rules.count
  end


  def getCellTextAtIndexPath(index_path)
    @rules[index_path.row].text
  end


  def body_height_for(text)
    cell_font = UIFont.fontWithName("Helvetica", size: 18.0)
    constraint_size = CGSizeMake(602, Float::MAX)
    label_size = text.sizeWithFont(cell_font, constrainedToSize: constraint_size, lineBreakMode: UILineBreakModeWordWrap)
    label_size.height
  end


  def tableView(table_view, cellForRowAtIndexPath: index_path)
    cell_identifier = "IpadDetailCell"

    cell = table_view.dequeueReusableCellWithIdentifier(cell_identifier)
    if cell.nil?
      NSBundle.mainBundle.loadNibNamed(cell_identifier, owner: self, options: nil)
      cell = tableCell
      tableCell = nil
    end

    header_label =  cell.viewWithTag(1)
    body_label = cell.viewWithTag(2)

    clause = rules[index_path.row]
    header_label.text = "#{clause.subsection}.#{clause.subsubsection}"
    body_label.text = clause.body

    body_label.lineBreakMode = UILineBreakModeWordWrap
    body_label.numberOfLines = 0
    body_label.font = UIFont.fontWithName("Helvetica", size: 18.0)
    body_frame = body_label.frame
    body_frame.size.height = body_height_for(clause.body)
    body_label.frame = body_frame
    cell
  end


  def height_for_row(row)
    body_height_for(@rules[row].body) + 54
  end


  def tableView(table_view, heightForRowAtIndexPath: index_path)
    height_for_row(index_path.row)
  end


  def tableViewHeight
    (0...@rules.count).inject(0.0) {|height, i| height + height_for_row(i) }
  end


  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    clause = @rules[index_path.row]
    more_rules = delegate.database.get_rules_referenced_by_rule(clause)

    unless more_rules.empty?
      pop_over_rules = IpadRulePopOverTableViewController.alloc.init
      pop_over_rules.rules = more_rules
      pop_over_rules.delegate = delegate
      f = view.frame
      pop_over_rules.view.frame = f

      @pop_over = UIPopoverController.alloc.initWithContentViewController(pop_over_rules)
      @pop_over.delegate = self
      @pop_over.popoverContentSize = f.size
      selected_cell = tableView.cellForRowAtIndexPath(index_path)

      @pop_over.presentPopoverFromRect(selected_cell.frame, inView: table_view, permittedArrowDirections: UIPopoverArrowDirectionAny, animated: true)
    end
  end


  def popoverControllerDidDismissPopover(popover_controller)
    view.deselectRowAtIndexPath(view.indexPathForSelectedRow, animated: true)
  end


end