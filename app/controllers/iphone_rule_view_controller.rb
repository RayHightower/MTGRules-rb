class IphoneRuleViewController < UITableViewController
  extend IB

  RULE_CELL_IDENTIFIER = "IphoneRuleCell"

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
    rules.count
  end


  def body_height_for(text)
    cell_font = UIFont.fontWithName("Helvetica", size: 14.0)
    constraint_size = CGSizeMake(self.view.frame.size.width - 40, Float::MAX)
    label_size = text.sizeWithFont(cell_font, constrainedToSize: constraint_size, lineBreakMode: UILineBreakModeWordWrap)
    label_size.height
  end


  def get_cell_text_at_index_path(index_path)
    clause = rules.objectAtIndex(index_path.row)
    clause.body
  end


  def tableView(table_view, cellForRowAtIndexPath: index_path)
    cell = table_view.dequeueReusableCellWithIdentifier(RULE_CELL_IDENTIFIER)
    if cell.nil?
      NSBundle.mainBundle.loadNibNamed(RULE_CELL_IDENTIFIER, owner: self, options: nil)
      cell = tableCell
      tableCell = nil
    end

    header_label = cell.viewWithTag(1)
    body_label = cell.viewWithTag(2)

    clause = rules[index_path.row]
    header_label.text = "#{clause.subsection}.#{clause.subsubsection}"
    body_label.text = clause.body

    body_label.lineBreakMode = UILineBreakModeWordWrap
    body_label.numberOfLines = 0
    body_label.font = UIFont.fontWithName("Helvetica", size: 14.0)
    body_frame = body_label.frame
    body_frame.size.height = body_height_for(body_label.text)
    body_label.frame = body_frame
    cell
  end


  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    self.view.deselectRowAtIndexPath(index_path, animated: false)
    clause = rules[index_path.row]
    referenced_rules = delegate.database.get_rules_referenced_by_rule(clause)

    if referenced_rules.count > 0
      rule_view_controller = IphoneRuleViewController.alloc.initWithNibName("IphoneRuleView", bundle: nil)
      rule_view_controller.rules = referenced_rules
      rule_view_controller.delegate = delegate
      rule_view_controller.title = "Rules"
      self.navigationController.pushViewController(rule_view_controller, animated: true)
    end
  end


  def tableView(tableView, heightForRowAtIndexPath: index_path)
    self.body_height_for(get_cell_text_at_index_path(index_path)) + 38
  end


end
