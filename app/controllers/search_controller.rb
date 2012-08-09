class SearchController < UIViewController
  extend IB

  attr_accessor :delegate, :searchBar, :resultsView, :searchDisplayController, :tableCell


  ## ib outlets
  ib_outlet :searchBar, UISearchBar
  ib_outlet :resultsView, UITableView
  ib_outlet :searchDisplayController, UISearchDisplayController
  ib_outlet :tableCell, UITableViewCell

  CELL_IDENTIFIER = "RuleCell"

  def searchBarTextDidEndEditing(search_bar)
    search_bar.resignFirstResponder
  end


  def searchBar(search_bar, textDidChange: search_text)
  end


  def searchBarSearchButtonClicked(search_bar)
    search_string = search_bar.text
    finishSearchWithString(search_string)
  end


  def searchBarCancelButtonClicked(search_bar)
  end


  def show_references_for(fragment)
    @results = delegate.search_for(fragment)
    if @results.size > 0
      searchDisplayController.searchResultsTableView.reloadData
      searchDisplayController.searchResultsTableView.scrollToRowAtIndexPath(NSIndexPath.indexPathForRow(0, inSection: 0), atScrollPosition: UITableViewScrollPositionTop, animated: false)
    end
  end


  def finishSearchWithString(search_string)
    show_references_for(search_string)
    searchBar.resignFirstResponder
  end


  def numberOfSectionsInTableView(table_view)
    1
  end


  def tableView(table_view, numberOfRowsInSection:section)
    @results ||= []
    @results.count
  end


  def body_height_for(text)
    cell_font = UIFont.fontWithName("Helvetica", size: 14.0)
    constraint_size = CGSizeMake(self.view.frame.size.width - 40, 100000.0)
    label_size = text.sizeWithFont(cell_font, constrainedToSize: constraint_size, lineBreakMode: UILineBreakModeWordWrap)
    label_size.height
  end


  def get_cell_text_at_index_path(index_path)
    @results[index_path.row].body
  end


  def tableView(table_view, heightForRowAtIndexPath: index_path)
    body_height_for(get_cell_text_at_index_path(index_path)) + 54
  end


  def tableView(table_view, cellForRowAtIndexPath: index_path)
    cell = table_view.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER)
    if cell.nil?
      NSBundle.mainBundle.loadNibNamed(CELL_IDENTIFIER, owner: self, options: nil)
      cell = tableCell
      tableCell = nil
    end
  
    header_label = cell.viewWithTag(1)
    body_label = cell.viewWithTag(2)
    
    detail = @results[index_path.row]
    header_label.text = detail.name
    body_label.text = detail.body
    body_label.lineBreakMode = UILineBreakModeWordWrap
    body_label.numberOfLines = 0
    body_label.font = UIFont.fontWithName("Helvetica", size: 14.0)
    body_frame = body_label.frame
    body_frame.size.height = body_height_for(body_label.text)
    body_label.frame = body_frame
    cell
  end


  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    detail = @results[index_path.row]
    referenced_rules = if detail.instance_of?(GlossaryEntry)
                         delegate.get_rules_referenced_by_glossary_term(detail.term)
                       else
                         delegate.get_rules_referenced_by_rule(detail)
                       end
    if referenced_rules.count > 0
      rule_view_controller = RuleViewController.alloc.initWithNibName("RuleViewController", bundle: nil)
      rule_view_controller.rules = referenced_rules
      rule_view_controller.delegate = delegate
      rule_view_controller.title = "Rules"
      navigationController().pushViewController(rule_view_controller, animated: true)
    end
  end

end
