class RootViewController < UITableViewController
  attr_accessor :delegate
  attr_accessor :contents

  
  def viewDidLoad
    view.dataSource = view.delegate = self
    self.title = "Rules"
  end

  
  def numberOfSectionsInTableView(table_view)
    1
  end

  
  def tableView(table_view, numberOfRowsInSection: section)
    10 #contents.number_of_children
  end

  
  def tableView(table_view, cellForRowAtIndexPath: index_path)
    cell = table_view.dequeueReusableCellWithIdentifier("Cell")
    cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "Cell") if cell.nil?

    # child = contents[index_path.row]
    # cell.accessoryType = child.has_children? ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone
    # cell.textLabel.text = child.text
    cell.textLabel.text = "Test"
    cell
  end


  def show_extra_info(key)
    # text = delegate.get_extra_info(key)
    # extras_controller = ExtrasController.alloc.initWithFrame()
  end
  
  
  def show_glossary
  end
  
  
  def tableView(table_view, didSelectRowAtIndexPath: index_path)
  end
  
  
  def search(sender)
  end
  
end