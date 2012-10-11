class Database


  def self.open(db_name)
    Database.new(db_name)
  end


  def initialize(db_name)
    @database = nil
    path = NSBundle.mainBundle.resourcePath.stringByAppendingPathComponent(db_name)
    @database = FMDatabase.databaseWithPath(path)
    if !@database.open
      @database = nil
    end
  end

  def open?
    !@database.nil?
  end


  def close
    @database.close if open?
    @database = nil
  end


  def load_subsub_contents_for(entry)
    results = @database.executeQuery('select section, subsection, subsubsection, text from contents where subsection = :subsection and subsubsection > 0 order by subsubsection', withParameterDictionary: {:subsection => entry.subsection})
    return if results.nil?
    while results.next
      section = results.intForColumnIndex(0)
      subsection = results.intForColumnIndex(1)
      subsubsection = results.intForColumnIndex(2)
      text = results.stringForColumnIndex(3)
      entry << ContentsEntry.new(section, subsection, subsubsection, text)
    end
  end


  def load_sub_contents_for(entry)
    results = @database.executeQuery('select section, subsection, text from contents where section = :section and subsection > 0 and subsubsection = 0 order by subsection', withParameterDictionary: {:section => entry.section})
    return if results.nil?
    while results.next
      section = results.intForColumnIndex(0)
      subsection = results.intForColumnIndex(1)
      text = results.stringForColumnIndex(2)
      entry << ContentsEntry.new(section, subsection, 0, text)
    end

    entry.children.each do |sub_entry|
      load_subsub_contents_for(sub_entry)
    end
  end


  def load_contents
    top_level_contents = ContentsEntry.new(0, 0, 0, 'Rules')
    return top_level_contents unless open?
    results = @database.executeQuery('select section, text from contents where subsection = 0 order by section')
    return top_level_contents if results.nil?
    while results.next
      section = results.intForColumnIndex(0)
      text = results.stringForColumnIndex(1)
      top_level_contents << ContentsEntry.new(section, 0, 0, text)
    end

    top_level_contents.children.each do |entry|
      load_sub_contents_for(entry)
    end

    top_level_contents
  end


  def get_extra_info(key)
    return '' unless open?
    results = @database.executeQuery('select body from extras where name = :name', withParameterDictionary: {:name => key})
    return '' if results.nil?
    return results.stringForColumnIndex(0) if results.next

    ''
  end


  def get_glossary
    glossary = []
    return glossary unless open?
    results = @database.executeQuery('select term, definition from glossary')
    return glossary if results.nil?
    while results.next
      term = results.stringForColumnIndex(0)
      definition = results.stringForColumnIndex(1)
      glossary << GlossaryEntry.new(term, definition)
    end
    glossary
  end


  def get_glossary_definition_for_term(term)
    return GlossaryEntry.empty_entry unless open?
    results = @database.executeQuery('select definition from glossary where term = :term', withParameterDictionary: {:term => term})
    return GlossaryEntry.empty_entry if results.nil?
    return GlossaryEntry.new(term, results.stringForColumnIndex(0)) if results.next
    GlossaryEntry.empty_entry
  end


  def get_rules_for_subsection(subsection)
    rules  = []
    return rules unless open?
    results = @database.executeQuery('select subsubsection, body from rules where subsection = :subsection and subsubsection > 0  order by subsubsection', withParameterDictionary: {:subsection => subsection})
    return rules if results.nil?
    while results.next
      subsubsection = results.stringForColumnIndex(0)
      text = results.stringForColumnIndex(1)
      rules << RuleClause.new(subsection, subsubsection, text)
    end
    rules
  end


  def get_rule_for_subsection(subsection, and_subsubsection: subsubsection)
    return nil unless open?
    clause = nil
    results = @database.executeQuery('select body from rules where subsection = :subsection and subsubsection = :subsubsection order by subsubsection', withParameterDictionary: {:subsection => subsection, :subsubsection => subsubsection})
    while results.next
      clause = RuleClause.new(subsection, subsubsection, results.stringForColumnIndex(0))
    end
    clause
  end


  def get_rules_for_subsection(subsection, and_subsubsection: subsubsection_root)
    rules = []
    return rules unless open?
    subsubsection_string = subsubsection_root < 10 ? "0#{subsubsection_root}%" : "#{subsubsection_root}%"
    results =  @database.executeQuery('select subsubsection, body from rules where subsection = :subsection and subsubsection like :subsubsection order by subsubsection', withParameterDictionary: {:subsection => subsection, :subsubsection => subsubsection_string})
    return rules if results.nil?
    while results.next
      subsubsection = results.stringForColumnIndex(0)
      text = results.stringForColumnIndex(1)
      rules << RuleClause.new(subsection, subsubsection, text)
    end
    rules
  end


  def get_rules_referenced_by_glossary_term(term)
    rules = []
    return rules unless open?
    results =  @database.executeQuery('select subsection, subsubsection, body from glossaryrefs indexed by glossaryrefsbyterm where term = :term order by subsection, subsubsection', withParameterDictionary: {:term => term})
    return rules if results.nil?
    while results.next
      subsection = results.intForColumnIndex(0)
      subsubsection = results.stringForColumnIndex(1)
      text = results.stringForColumnIndex(2)
      rules << RuleClause.new(subsection, subsubsection, text)
    end
    rules
  end


  def get_rules_referenced_by_rule(clause)
    rules = []
    return rules unless open?
    results =  @database.executeQuery('select subsection, subsubsection, body from rulerefs indexed by rulerefsbyrule where rule = :rule order by subsection, subsubsection', withParameterDictionary: {:rule => clause.name})
    return rules if results.nil?
    while results.next
      subsection = results.intForColumnIndex(0)
      subsubsection = results.stringForColumnIndex(1)
      text = results.stringForColumnIndex(2)
      rules << RuleClause.new(subsection, subsubsection, text)
    end
    rules
  end


  def get_thing_for(key1, key2)
    if key1 == 'glossary'
      get_glossary_definition_for_term(key2)
    else
      get_rule_for_subsection(key1.to_i, and_subsubsection: key2)
    end
  end


  def search_for(fragment)
    items = []
    return items unless open?
    results =  @database.executeQuery('select key1, key2 from searchindex indexed by searchindexbyterm where searchterm = :searchterm order by key1, key2', withParameterDictionary: {:searchterm => fragment})
    return items if results.nil?
    while results.next
      key1 = results.stringForColumnIndex(0)
      key2 = results.stringForColumnIndex(1)
      items << get_thing_for(key1, key2)
    end
    items
  end


end
