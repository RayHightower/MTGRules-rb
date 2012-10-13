class IpadSubSubSectionMenuController < UITableViewController
  attr_accessor :delegate, :contents, :detail_view_controller


  def viewDidLoad
    super
    self.title = contents.text
  end


  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    true
  end


  def numberOfSectionsInTableView(table_view)
    1
  end


  def tableView(table_view, numberOfRowsInSection: section)
    contents.size
  end


  def tableView(table_view, cellForRowAtIndexPath: index_path)
    cell_identifier = "Cell"

    cell = table_view.dequeueReusableCellWithIdentifier(cell_identifier)
    if cell.nil?
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: cell_identifier)
    end

    child = contents[index_path.row]
    cell.textLabel.text = child.text

    cell
  end


  def showRulesFor(entry)
    rules = delegate.database.get_rules_for_subsection(entry.subsection, and_subsubsection: entry.subsubsection)
    @detail_view_controller.detail_item = rules
    @detail_view_controller.titleItem.title = "#{contents.text} - #{entry.text}"
  end


  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    child = contents[index_path.row]
    self.showRulesFor(child)
  end


end
