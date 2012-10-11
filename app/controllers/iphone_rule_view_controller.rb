class IphoneRuleViewController < UITableViewController
  extend IB

  RULE_CELL_IDENTIFIER = "RuleCell"

  attr_accessor :delegate
  attr_accessor :tableCell
  attr_accessor :rules

  ib_outlet :tableCell, UITableViewCell


  def numberOfSectionsInTableView(table_view)
    1
  end


  def tableView(table_view, numberOfRowsInSection: section)
    rules.count
  end


  def body_height_for(text)
    cellFont = UIFont.fontWithName("Helvetica", size: 14.0)
    constraintSize = CGSizeMake(self.view.frame.size.width - 40, 100000)
    labelSize = text.sizeWithFont(cellFont, constrainedToSize: constraintSize, lineBreakMode: UILineBreakModeWordWrap)
    labelSize.height
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
      rule_view_controller = IphoneRuleViewController.alloc.initWithNibName("IphoneRuleViewController", bundle: nil)
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
