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


  def searchBarSearchButtonClicked(aSearchBar)
    searchString = searchBar.text 
    # recentSearchesController.addToRecentSearches(searchString)
    self.finishSearchWithString(searchString)
  end


  def searchBarCancelButtonClicked(aSearchBar)
    @detail_view_controller.dismiss_search_controller(self)
  end


  def showReferencesFor(fragment)
    @results = delegate.database.search_for(fragment)
    searchDisplayController.searchResultsTableView.reloadData
    searchDisplayController.searchResultsTableView.scrollToRowAtIndexPath(NSIndexPath.indexPathForRow(0, inSection: 0), atScrollPosition: UITableViewScrollPositionTop, animated: false)
  end


  def finishSearchWithString(searchString)
    showReferencesFor(searchString)
    # recentSearchesPopoverController.dismissPopoverAnimated(true)
    searchBar.resignFirstResponder
  end


  def popoverControllerDidDismissPopover(popoverController)
    # if popoverController == recentSearchesPopoverController
    #   searchBar.resignFirstResponder
    # else
      searchDisplayController.searchResultsTableView.deselectRowAtIndexPath(searchDisplayController.searchResultsTableView.indexPathForSelectedRow, animated: true)
    # end
  end


  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @results.size
  end

  def bodyHeightFor(text)
    cellFont = UIFont.fontWithName("Helvetica", size: 18.0)
    constraintSize = CGSizeMake(view.frame.size.width - 75, Float::MAX)
    labelSize = text.sizeWithFont(cellFont, constrainedToSize: constraintSize, lineBreakMode: UILineBreakModeWordWrap)
    labelSize.height
  end


  def getCellTextAtIndexPath(indexPath)
    @results[indexPath.row].body
  end


  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    bodyHeightFor(getCellTextAtIndexPath(indexPath)) + 54
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cellIdentifier = "IpadDetailCell"

    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
    if cell.nil?
      NSBundle.mainBundle.loadNibNamed(cellIdentifier, owner: self, options: nil)
      cell = tableCell
      tableCell = nil
    end

    headerLabel = cell.viewWithTag(1)
    bodyLabel = cell.viewWithTag(2)

    detail = @results[indexPath.row]
    headerLabel.text =  detail.is_a?(GlossaryEntry) ? detail.name : "#{detail.subsection}.#{detail.subsubsection}"
    bodyLabel.text = detail.body
    bodyLabel.lineBreakMode = UILineBreakModeWordWrap
    bodyLabel.numberOfLines = 0
    bodyLabel.font = UIFont.fontWithName("Helvetica", size: 18.0)
    bodyFrame = bodyLabel.frame
    bodyFrame.size.height = bodyHeightFor(detail.body)
    bodyLabel.frame = bodyFrame
    cell
  end


  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    detail = @results[indexPath.row]
    rules = detail.is_a?(GlossaryEntry) ? delegate.database.get_rules_referenced_by_glossary_term(detail.term) : delegate.database.get_rules_referenced_by_rule(detail)

    if rules.count > 0
      popOverRules = IpadRulePopOverTableViewController.alloc.init
      popOverRules.rules = rules
      popOverRules.delegate = delegate
      f = view.frame
      f.size.width -= 50
      tableHeight = popOverRules.tableViewHeight
      shortenBy = (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ? 100 : 50
      maxHeight = f.size.height - shortenBy
      f.size.height = (tableHeight < maxHeight) ? tableHeight : maxHeight
      popOverRules.view.frame = f

      @popOver = UIPopoverController.alloc.initWithContentViewController(popOverRules)
      @popOver.delegate = self
      @popOver.popoverContentSize = f.size
      selectedCell = tableView.cellForRowAtIndexPath(indexPath)

      @popOver.presentPopoverFromRect(selectedCell.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirectionAny, animated: true)
    end
  end

end
