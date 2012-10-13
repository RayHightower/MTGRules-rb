class IpadSearchController < UIViewController
  extend IB

  attr_accessor :delegate, :detail_view_controller

  outlet :searchBar, UISearchBar
  outlet :resultsView, UITableView
  outlet :searchDisplayController, UISearchDisplayController
  outlet :tableCell, UITableViewCell


  def viewDidLoad
    super
    @results = []
  end


  # def recentSearchesController(controller, didSelectString: searchString)
  #   searchBar.text = searchString
  #   finishSearchWithString(searchString)
  # end
  # 
  # 
  # def searchBarTextDidBeginEditing(aSearchBar)
  #   recentSearchesPopoverController.presentPopoverFromRect(searchBar.bounds, inView: searchBar, permittedArrowDirections: UIPopoverArrowDirectionAny, animated: true)
  # end
  # 
  # 
  # def searchBarTextDidEndEditing(aSearchBar)
  #   recentSearchesPopoverController.dismissPopoverAnimated(true)
  #   aSearchBar.resignFirstResponder
  # end
  # 
  # 
  # def searchBar(searchBar, textDidChange: searchText)
  #   recentSearchesController.filterResultsUsingString(searchText)
  # end


  def searchBarSearchButtonClicked(search_bar)
    search_string = searchBar.text 
    # recentSearchesController.addToRecentSearches(search_string)
    self.finishSearchWithString(search_string)
  end


  def searchBarCancelButtonClicked(search_bar)
    @detail_view_controller.dismiss_search_controller(self)
  end


  def showReferencesFor(fragment)
    @results = delegate.database.search_for(fragment)
    searchDisplayController.searchResultsTableView.reloadData
    searchDisplayController.searchResultsTableView.scrollToRowAtIndexPath(NSIndexPath.indexPathForRow(0, inSection: 0), atScrollPosition: UITableViewScrollPositionTop, animated: false)
  end


  def finishSearchWithString(search_string)
    showReferencesFor(search_string)
    # recentSearchesPopoverController.dismissPopoverAnimated(true)
    searchBar.resignFirstResponder
  end


  def popoverControllerDidDismissPopover(popover_controller)
    # if popover_controller == recentSearchesPopoverController
    #   searchBar.resignFirstResponder
    # else
      searchDisplayController.searchResultsTableView.deselectRowAtIndexPath(searchDisplayController.searchResultsTableView.indexPathForSelectedRow, animated: true)
    # end
  end


  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    true
  end

  def numberOfSectionsInTableView(table_view)
    1
  end

  def tableView(table_view, numberOfRowsInSection: section)
    @results.size
  end

  def body_height_for(text)
    cell_font = UIFont.fontWithName("Helvetica", size: 18.0)
    constraint_size = CGSizeMake(view.frame.size.width - 75, Float::MAX)
    label_size = text.sizeWithFont(cell_font, constrainedToSize: constraint_size, lineBreakMode: UILineBreakModeWordWrap)
    label_size.height
  end


  def getCellTextAtIndexPath(index_path)
    @results[index_path.row].body
  end


  def tableView(table_view, heightForRowAtIndexPath: index_path)
    body_height_for(getCellTextAtIndexPath(index_path)) + 54
  end


  def tableView(table_view, cellForRowAtIndexPath: index_path)
    cell_identifier = "IpadDetailCell"

    cell = table_view.dequeueReusableCellWithIdentifier(cell_identifier)
    if cell.nil?
      NSBundle.mainBundle.loadNibNamed(cell_identifier, owner: self, options: nil)
      cell = tableCell
      tableCell = nil
    end

    header_label = cell.viewWithTag(1)
    body_label = cell.viewWithTag(2)

    detail = @results[index_path.row]
    header_label.text =  detail.is_a?(GlossaryEntry) ? detail.name : "#{detail.subsection}.#{detail.subsubsection}"
    body_label.text = detail.body
    body_label.lineBreakMode = UILineBreakModeWordWrap
    body_label.numberOfLines = 0
    body_label.font = UIFont.fontWithName("Helvetica", size: 18.0)
    body_frame = body_label.frame
    body_frame.size.height = body_height_for(detail.body)
    body_label.frame = body_frame
    cell
  end


  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    detail = @results[index_path.row]
    rules = detail.is_a?(GlossaryEntry) ? delegate.database.get_rules_referenced_by_glossary_term(detail.term) : delegate.database.get_rules_referenced_by_rule(detail)

    if rules.count > 0
      pop_over_rules = IpadRulePopOverTableViewController.alloc.init
      pop_over_rules.rules = rules
      pop_over_rules.delegate = delegate
      f = view.frame
      f.size.width -= 50
      table_height = pop_over_rules.tableViewHeight
      shorten_by = (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ? 100 : 50
      max_height = f.size.height - shorten_by
      f.size.height = [table_height, max_height].min
      pop_over_rules.view.frame = f

      @pop_over = UIPopoverController.alloc.initWithContentViewController(pop_over_rules)
      @pop_over.delegate = self
      @pop_over.popoverContentSize = f.size
      selected_cell = table_view.cellForRowAtIndexPath(index_path)

      @pop_over.presentPopoverFromRect(selected_cell.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirectionAny, animated: true)
    end
  end

end
