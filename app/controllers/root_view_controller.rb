class RootViewController < UITableViewController

  attr_accessor :delegate, :contents

  def viewDidLoad
    view.dataSource = view.delegate = self
    self.title = "Rules"
  end


  def numberOfSectionsInTableView(table_view)
    1
  end


  def tableView(table_view, numberOfRowsInSection: section)
    contents.size
  end


  def tableView(table_view, cellForRowAtIndexPath: index_path)
    cell = table_view.dequeueReusableCellWithIdentifier("Cell") || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "Cell")

    child = contents[index_path.row]
    cell.accessoryType = child.has_children? ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone
    cell.textLabel.text = child.text
    cell
  end


  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    child = contents.children[index_path.row]
    if child.has_children?
      show_section(child)
    elsif index_path.row == 0
      show_extra_info("Intro")
    elsif index_path.row == contents.size - 3
      show_glossary
    elsif index_path.row == contents.size - 2
      show_extra_info("Credits")
    elsif index_path.row == contents.size - 1
      show_extra_info("Customer Service Information")
    end
  end


  def didReceiveMemoryWarning
    super.didReceiveMemoryWarning
  end

end
