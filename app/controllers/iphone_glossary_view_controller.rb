class IphoneGlossaryViewController < UITableViewController
  extend IB

  GLOSSARY_CELL_IDENTIFIER = "IphoneGlossaryCell"

  attr_accessor :delegate
  attr_accessor :tableCell
  attr_accessor :glossary

  ib_outlet :tableCell, UITableViewCell


  def viewDidLoad
    super
    title = "Rules"
  end


  def glossary=(new_glossary)
    if @glossary != new_glossary
      @glossary = new_glossary

      @glossary_entries = []
      the_collation = UILocalizedIndexedCollation.currentCollation
      @glossary.each do |item|
        sect = the_collation.sectionForObject(item, collationStringSelector: :name)
        item.section_number = sect
      end

      high_section = the_collation.sectionTitles.count
      section_arrays = []
      (0..high_section).each do |i|
        section_array = []
        section_arrays << section_array
      end

      glossary.each do |item|
        section_arrays[item.section_number] << item
      end

      section_arrays.each do |section_array|
        sorted_section = the_collation.sortedArrayFromArray(section_array, collationStringSelector: :name)
        @glossary_entries << sorted_section
      end

      self.view.reloadData
      self.view.scrollToRowAtIndexPath(NSIndexPath.indexPathForRow(0, inSection:0), atScrollPosition: UITableViewScrollPositionTop, animated:false)
    end
  end


  def sectionIndexTitlesForTableView(table_view)
    UILocalizedIndexedCollation.currentCollation.sectionIndexTitles
  end


  def tableView(table_view, titleForHeaderInSection: section)
    if @glossary_entries[section].count > 0
      UILocalizedIndexedCollation.currentCollation.sectionTitles[section]
    else
      nil
    end
  end


  def tableView(table_view, sectionForSectionIndexTitle: title, atIndex: index)
    UILocalizedIndexedCollation.currentCollation.sectionForSectionIndexTitleAtIndex(index)
  end


  def numberOfSectionsInTableView(table_view)
    @glossary_entries.count
  end


  def tableView(tableView, numberOfRowsInSection: section)
    @glossary_entries[section].count
  end


  def body_height_for(text)
    cellFont = UIFont.fontWithName("Helvetica", size: 14.0)
    constraintSize = CGSizeMake(self.view.frame.size.width - 40, 100000)
    label_size = text.sizeWithFont(cellFont, constrainedToSize: constraintSize)
    label_size.height
  end


  def entry_at_index_path(index_path)
    @glossary_entries[index_path.section][index_path.row]
  end


  def tableView(table_view, cellForRowAtIndexPath: index_path)

    cell = table_view.dequeueReusableCellWithIdentifier(GLOSSARY_CELL_IDENTIFIER)
    if cell.nil?
      NSBundle.mainBundle.loadNibNamed(GLOSSARY_CELL_IDENTIFIER, owner: self, options: nil)
      cell = @tableCell
      @tableCell = nil;
    end

    headerLabel = cell.viewWithTag(1)
    bodyLabel = cell.viewWithTag(2)

    entry = entry_at_index_path(index_path)
    headerLabel.text = entry.name
    bodyLabel.text = entry.body

    bodyLabel.lineBreakMode = UILineBreakModeWordWrap
    bodyLabel.numberOfLines = 0
    bodyLabel.font = UIFont.fontWithName("Helvetica", size: 14.0)
    bodyFrame = bodyLabel.frame
    bodyFrame.origin.y = 30
    bodyFrame.size.height = self.body_height_for(bodyLabel.text) + 30
    bodyLabel.frame = bodyFrame
    cell
  end


  def get_cell_text_at_index_path(index_path)
    entry_at_index_path(index_path).body
  end


  def tableView(table_view, didSelectRowAtIndexPath:index_path)
    self.view.deselectRowAtIndexPath(index_path, animated: false)
    entry = entry_at_index_path(index_path)
    referenced_rules = delegate.database.get_rules_referenced_by_glossary_term(entry.name)

    if referenced_rules.count > 0
      ruleViewController = RuleViewController.alloc.initWithNibName("RuleView", bundle: nil)
      ruleViewController.rules = referenced_rules
      ruleViewController.delegate = delegate
      ruleViewController.title = "Rules"
      navigationController().pushViewController(ruleViewController, animated: true)
    end
  end


  def tableView(tableView, heightForRowAtIndexPath: index_path)
    body_height_for(self.get_cell_text_at_index_path(index_path)) + 60
  end

end
