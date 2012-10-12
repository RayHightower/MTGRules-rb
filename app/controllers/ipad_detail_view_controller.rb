class IpadDetailViewController < UIViewController
  extend IB

  attr_accessor :detail_item, :delegate, :popover_controller

  outlet :toolbar, UIToolbar
  outlet :detailWebView, UIWebView
  outlet :detailTableView, UITableView
  outlet :tableCell, UITableViewCell
  outlet :titleItem, UIBarButtonItem
  outlet :searchButton, UIBarButtonItem


  def configure_view
    if detail_item.is_a? String
      @is_glossary = false
      html_string = detailItem.split("\n").collect {|line| "<p>#{line}</p>"}.join
      detailWebView.loadHTMLString(html_string, baseURL: nil)
      detailTableView.hidden = true
      detailWebView.hidden = false
    else
      @is_glossary = detail_item[0].is_a? GlossaryEntry

      if @is_glossary
        @detail_items = []
        the_collation = UILocalizedIndexedCollation.currentCollation
        detail_item.each do |item|
          sect = the_collation.sectionForObject(item, collationStringSelector: :name)
          item.section_number = sect
        end

        high_section = the_collation.sectionTitles.count
        section_arrays = []
        (0..high_section).each {|i| section_arrays << [] }

        detal_item_array.each {|i| section_arrays[item.section_number] << item }

        section_arrays.each { |section_array| @detail_items << the_collation.sortedArrayFromArray(section_array, collationStringSelector: :name) }
      else
        @detail_tems = detail_item.clone
      end

      detailTableView.hidden = false
      detailWebView.hidden = true
      detailTableView.reloadData
      detailTableView.scrollToRowAtIndexPath(NSIndexPath.indexPathForRow(0, inSection: 0), atScrollPosition: UITableViewScrollPositionTop, animated: false)
    end
  end


  def detail_item=(new_detail_item)
    if @detail_item != new_detail_item
      detail_item = new_detail_item
      configure_view
    end

    popoverController.dismissPopoverAnimated(true) unless popoverController.nil?
  end


  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end


  def didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    if detail_item.is_a? String
      configureView
    else
      detailTableView.reloadData
    end
  end


  def open_search_controller
    search_controller = IPadSearchController.alloc.initWithNibName("IPadSearchView", bundle: nil)
    search_controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal
    search_controller.modalPresentationStyle = UIModalPresentationFullScreen
    search_controller.detailViewController = self
    search_controller.delegate = self.delegate
    presentModalViewController(search_controller, animated: true)
  end


  def dismiss_search_controller(search_controller)
    dismissModalViewControllerAnimated(true)
  end


  def select(sender)
    open_search_controller
  end

  ib_action :select


  def splitViewController(svc, willHideViewController: a_view_controller, withBarButtonItem: bar_button_item, forPopoverController: pc)
    bar_button_item.title = "Contents"
    items = toolbar.items.clone
    items.insert(0, barButtonItem)
    toolbar.setItems(items, animated:YES)
    @popoverController = pc
  end

  def splitViewController(svc, willShowViewController: a_view_controller, invalidatingBarButtonItem: bar_button_item)
    items = toolbar.items.clone
    items.delete_at(0)
    toolbar.setItems(items, animated: true)
    @popover_controller = nil
  end


  def viewDidUnload
    @popoverController = nil
  end


  def sectionIndexTitlesForTableView(tableView )
    return @is_glossary ? UILocalizedIndexedCollation.currentCollation.sectionIndexTitles : nil;
  end


  def tableView(tableView, titleForHeaderInSection: section)
    return UILocalizedIndexedCollation.currentCollation.sectionTitles[section] if is_glossary && detailItems.count > 0
    nil
  end


  def tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
    UILocalizedIndexedCollation.currentCollation.sectionForSectionIndexTitleAtIndex(index)
  end


  def numberOfSectionsInTableView(tableView)
    @is_glossary ? detailItems.count : 1
  end


  def tableView(tableView, numberOfRowsInSection: section)
    @is_glossary ? detailItems[section].count : detailItems.count
  end


  def bodyHeightFor(text)
    cellFont = UIFont.fontWithName("Helvetica", size: 18.0)
    constraintSize = CGSizeMake(detailTableView.frame.size.width - 75, Float::MAX)
    labelSize = text.sizeWithFont(cellFont, constrainedToSize: constraintSize)
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

    headerLabel = cell.viewWithTag(1)
    bodyLabel = cell.viewWithTag(2)

    id detail = @is_glossary ? detailItems[indexPath.section][indexPath.row] : detailItems[indexPath.row]
    if detail.is_a? GlossaryEntry
      headerLabel.text = detail.term
    else
      headerLabel.text = detail.subsubsection;
    end
    bodyLabel.text = detail.body
    bodyLabel.lineBreakMode = UILineBreakModeWordWrap
    bodyLabel.numberOfLines = 0
    bodyLabel.font = UIFont.fontWithName("Helvetica", size: 18.0)
    bodyFrame = bodyLabel.frame
    bodyFrame.size.height = bodyHeightFor(bodyLabel.text)
    bodyLabel.frame = bodyFrame
    cell
  end


  def getCellTextAtIndexPath(indexPath)
    detail = @is_glossary ? detailItems[indexPath.section][indexPath.row] : detailItems[indexPath.row]
    detail.body
  end


  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    bodyHeightFor(getCellTextAtIndexPath(indexPath)) + 54
  end


  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    detail = @is_glossary ? detailItems[indexPath.section][indexPath.row] : detailItems[indexPath.row]
    rules = @is_glossary ? delegate.getRulesReferencedByGlossaryTerm(entry.term) : delegate.getRulesReferencedByRule(detail)

    if rules.count > 0
      popOverRules = IPadRulePopOverTableViewController.alloc.init
      popOverRules.rules = rules
      popOverRules.delegate = delegate
      f = self.view.window.frame
      f.size.width -= 50
      tableHeight = popOverRules.tableViewHeight
      shortenBy = (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ? 100 : 50
      maxHeight = f.size.height - shortenBy
      f.size.height = (tableHeight < maxHeight) ? tableHeight : maxHeight
      popOverRules.view.frame = f

      popOver = UIPopoverController.alloc.initWithContentViewController(popOverRules)
      popOver.delegate = self
      popOverRules.contentSizeForViewInPopover = f.size
      popOver.popoverContentSize = f.size
      selectedCell = tableView.cellForRowAtIndexPath(indexPath)

      popOver.presentPopoverFromRect(selectedCell.frame, inView: view, permittedArrowDirections: UIPopoverArrowDirectionAny, animated: true)
    end
  end


  def popoverControllerDidDismissPopover(popoverController)
    detailTableView.deselectRowAtIndexPath(detailTableView.indexPathForSelectedRow, animated: true)
  end


end
