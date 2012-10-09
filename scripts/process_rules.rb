require 'set'

class Emitter

  def dequote(str)
    str.gsub("'", "''")
  end

  
  def dehtml(str)
    str.gsub("'", "''").gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub(/_([^_]+)_/, '<b>\1</b>')
  end

  
  def emit_content_line(section, subsection, subsubsection, text)
    puts "insert into contents(section, subsection, subsubsection, text) values (#{section}, #{subsection}, #{subsubsection}, '#{dequote(text)}');"
  end

  
  def emit_contents(contents)
    puts "drop table contents;"
    puts "create table contents('section' integer, 'subsection' integer, 'subsubsection' integer, 'text' text);"
    contents.each_with_index do |section_data, section_number|
      emit_content_line(section_number, 0, 0, section_data[:text]) if section_data.has_key?(:text)
      if section_data.has_key?(:subsections)
        section_data[:subsections].sort.each do |subsection_number, subsection_data|
          emit_content_line(section_number, subsection_number, 0, subsection_data[:text]) if subsection_data.has_key?(:text)
          if subsection_data.has_key?(:subsections)
            subsection_data[:subsections].sort.each do |subsubsection_number, subsubsection_data|
              emit_content_line(section_number, subsection_number, subsubsection_number, subsubsection_data[:text]) if subsubsection_data.has_key?(:text)
            end
          end
        end
      end
    end
  end
    

  def emit_rules(rules)
    puts "drop table rules;"
    puts "create table rules('subsection' integer, 'subsubsection' text, 'body' text);"
    rules.sort.each do |subsection, subsection_data|
      subsection_data.sort.each do |subsubsection, text|
        puts "insert into rules(subsection, subsubsection, body) values (#{subsection}, '#{subsubsection}', '#{dequote(text)}');"
      end
    end
  end


  def emit_glossary(glossary)
    puts "drop table glossary;"
    puts "create table glossary('term' text, 'definition' text);"
    glossary.sort.each do |term, definition|
      puts "insert into glossary(term, definition) values ('#{dequote(term)}', '#{dequote(definition)}');"
    end
  end

  
  def emit_extras_line(section, text)
    puts "insert into extras(name, body) values ('#{section}', '#{text}');"
  end
  

  def emit_extras(intro, credits, customer_service)
    puts "drop table extras;\n"
    puts "create table extras('name' text, 'body' text);"
    emit_extras_line("Intro", dehtml(intro))
    emit_extras_line("Credits", dehtml(credits))
    emit_extras_line("Customer Service Information", dequote(customer_service))
  end

  
  def emit_glossary_rule_references(glossary_rules_references, rules)
    puts "drop table glossaryrefs;"
    puts "create table glossaryrefs(term text, subsection integer, subsubsection text, body text);"
    glossary_rules_references.each do |term, refs|
      refs.each do |ref|
        subsection, subsubsection = ref.split('.')
        subsubsection = "" if subsubsection.nil?
        body = rules[subsection.to_i][subsubsection]
        puts "insert into glossaryrefs(term, subsection, subsubsection, body) values ('#{dequote(term)}', #{subsection}, '#{subsubsection}', '#{dequote(body)}');"
      end
    end
  end

  
  def emit_inter_rule_references(inter_rules_references, rules)
    puts "drop table rulerefs;"
    puts "create table rulerefs(rule text, subsection integer, subsubsection text, body text);"
    inter_rules_references.each do |rule, refs|
      refs.each do |ref|
        subsection, subsubsection = ref.split('.')
        subsubsection = "" if subsubsection.nil?
        body = rules[subsection.to_i][subsubsection]
        puts "insert into rulerefs(rule, subsection, subsubsection, body) values ('#{rule}', #{subsection}, '#{subsubsection}', '#{dequote(body)}');"
      end
    end
  end
  
  def emit_index(index)
    puts "drop table searchindex;"
    puts "create table searchindex(searchterm text, key1 text, key2 text);"
    index.each do |index_term, index_entries|
      index_entries.each do |entry|
        puts "insert into searchindex(searchterm, key1, key2) values ('#{dequote(index_term)}', '#{entry[0]}', '#{dequote(entry[1])}');"
      end
    end
  end


  def emit_indicies
    puts "create index glossaryrefsbyterm on glossaryrefs(term asc);"
    puts "create index rulerefsbyrule on rulerefs(rule asc);"
    puts "create index searchindexbyterm on searchindex(searchterm asc);"
  end
  

end

class Reader

  attr_reader :intro, :contents, :rules, :glossary, :credits, :customer_service, :glossary_rules_references, :inter_rules_references, :index
  
  def initialize(filename)
    @data = File.open(filename, "r") {|f| f.readlines}
    @contents = []
  end

  
  def extract_intro
    intro_end = @data.find_index {|line| line.start_with?("Contents")} - 1
    @intro = @data[0..intro_end].map {|l| l.strip}.join("\n")
    @contents << {:text => "Introduction"}
  end

  
  def extract_contents
    current_section = nil
    start_new_section = false
    contents_start = @data.find_index {|line| line.start_with?("Contents")} + 1
    contents_end = @data.find_index {|line| line.start_with?("Customer Service")} + 1

    (contents_start..contents_end).each do |line_number|
      line = @data[line_number].strip
      if line.empty?
        start_new_section = true
      elsif start_new_section
        start_new_section = false
        current_section = Hash.new
        if line =~ /([^\.]+)\. (.*)$/
          current_section[:text] = $2
        else
          current_section[:text] = line
        end
        current_section[:subsections] = Hash.new
        @contents << current_section
      else
        line =~ /([^\.]+)\. (.*)$/
        current_section[:subsections][$1.to_i] = Hash.new
        current_section[:subsections][$1.to_i][:text] = $2
      end
    end
  end

  
  def extract_keyword_actions
    contents_end = @data.find_index {|line| line.start_with?("Customer Service")} + 1
    body = @data[contents_end..-1]
    @keyword_actions = Hash.new
    start = body.find_index {|line| line.include?("Keyword Actions")}
    body[start] =~ /^([0-9]+)\. (.*)$/
    section = $1
    body[(start + 1)..-1].each do |line|
      unless line.strip.empty?
        unless line.start_with?(section) || !(line =~ /^([0-9]+)\.([0-9]+)\. (.*)/)
          @contents[section.to_i / 100][:subsections][section.to_i][:subsections] = @keyword_actions
          return
        end
        line =~ /^([0-9]+)\.([0-9]+)\. (.*)/
        subsection = $2
        text = $3
        if text && text.split.length < 4
          @keyword_actions[subsection] = Hash.new
          @keyword_actions[subsection][:text] = text.strip
        end
      end
    end
  end

  
  def extract_keyword_abilities
    contents_end = @data.find_index {|line| line.start_with?("Customer Service")} + 1
    body = @data[contents_end..-1]
    @keyword_abilities = Hash.new
    start = body.find_index {|line| line =~ /[0-9]+\. Keyword Abilities/}
    body[start] =~ /^([0-9]+)\. (.*)$/
    section = $1
    body[(start + 1)..-1].each do |line|
      unless line.strip.empty?
        unless line.start_with?(section) || !(line =~ /^([0-9]+)\.([0-9]+)\. (.*)/)
          @contents[section.to_i / 100][:subsections][section.to_i][:subsections] = @keyword_abilities
          return
        end
        line =~ /^([0-9]+)\.([0-9]+)\. (.*)/
        subsection = $2
        text = $3
        if text && text.split.length < 4
          @keyword_abilities[subsection] = Hash.new
          @keyword_abilities[subsection][:text] = text.strip
        end
      end
    end
  end


  def extract_rules
    contents_end = @data.find_index {|line| line.start_with?("Customer Service")} + 1
    glossary_start = @data[contents_end..-1].find_index {|line| line.strip == "Glossary"} - 1 + contents_end
    body = @data[contents_end..glossary_start]
    @rules = Hash.new
    subsection = nil
    subsubsection = nil
    rule = []

    body.each do |line|
      if (line.strip.empty?)
        if subsection
          if @rules[subsection].nil?
            @rules[subsection] = Hash.new
          end
          @rules[subsection][subsubsection] = rule.join("\n")
          rule = []
        end
        subsection = nil
      elsif subsection.nil?
        if line =~ /^([0-9]+)\.(([0-9]+)([a-z]?)\.?)? (.*)$/
          subsection = $1.to_i
          if $2.nil?
            subsubsection = ""
          else
            subsubsection_number = $3.to_i
            suffix = $4
            prefix = (subsubsection_number < 10) ? '0' : ''
            subsubsection = "#{prefix}#{$3}#{suffix}"
          end
          rule << $5.strip
        end
      else
        rule << line.strip
      end
    end
  end


  def extract_glossary
    contents_end = @data.find_index {|line| line.start_with?("Customer Service")} + 1
    glossary_start = @data[contents_end..-1].find_index {|line| line.strip == "Glossary"} + 1 + contents_end
    glossary_end = @data[glossary_start..-1].find_index {|line| line.strip == "Credits"} - 1 + glossary_start
    body = @data[glossary_start..glossary_end]

    @glossary = Hash.new
    current_entry = nil
    body.each do |line|
      if line.strip.empty?
        @glossary[current_entry] = @glossary[current_entry].strip if @glossary[current_entry]
        current_entry = nil
      elsif current_entry.nil?
        current_entry = line.strip
        @glossary[current_entry] = ""
      else
        @glossary[current_entry] = @glossary[current_entry] + line
      end
    end
  end
  
  
  def zero_pad_if_needed(subsubsection)
    if (subsubsection.start_with?('0'))
      subsubsection
    else
      subsubsection.to_i < 10 ? "0#{subsubsection}" : subsubsection
    end
  end
  
  
  
  def find_references_in(text)
    matches = []
    text.scan(/section ([0-9]{1})[^0-9]/) do |section|
      @rules.each do |subsection, subsubsections|
        if (subsection / 100) == section[0].to_i
          subsubsections.each_key do |subsubsection| 
            subsubsection_string = subsubsection.empty? ? '' : ".#{zero_pad_if_needed(subsubsection)}"
            match_string = "#{subsection}#{subsubsection_string}"
            matches << match_string unless matches.include?(match_string)
          end
        end
      end
    end
    
    text.scan(/rule ([0-9]{3})([^0-9\.]|(\.[^0-9])|(\.$))/) do |subsection, n1, n2|
      @rules[subsection.to_i].each_key do |subsubsection|
        subsubsection_string = subsubsection.empty? ? '' : ".#{zero_pad_if_needed(subsubsection)}"
        match_string = "#{subsection}#{subsubsection_string}"
        matches << match_string unless matches.include?(match_string)        
      end
    end
    
    text.scan(/rules ([0-9]{3}) and ([0-9]{3})([^0-9\.]|(\.[^0-9])|(\.$))/) do |subsection1, subsection2, n1, n2|
      @rules[subsection1.to_i].each_key do |subsubsection|
        subsubsection_string = subsubsection.empty? ? '' : ".#{zero_pad_if_needed(subsubsection)}"
        match_string = "#{subsection1}#{subsubsection_string}"
        matches << match_string unless matches.include?(match_string)        
      end
      @rules[subsection2.to_i].each_key do |subsubsection|
        subsubsection_string = subsubsection.empty? ? '' : ".#{zero_pad_if_needed(subsubsection)}"
        match_string = "#{subsection2}#{subsubsection_string}"
        matches << match_string unless matches.include?(match_string)        
      end
    end
    
    text.scan(/([0-9]{3})\.([0-9]+)([a-z])-([a-z])/) do |subsection, subsubsection_root, first_clause, last_clause|
      subsubsection_prefix = zero_pad_if_needed(subsubsection_root)
      (first_clause..last_clause).each do |clause|
        match_string = "#{subsection}.#{subsubsection_prefix}#{clause}"
        matches << match_string unless matches.include?(match_string)
      end
    end
    
    text.scan(/([0-9]{3})\.([0-9]+[a-z])[^\-]/) do |subsection, clause|
      clause_string = zero_pad_if_needed(clause)
      match_string = "#{subsection}.#{clause_string}"
      matches << match_string unless matches.include?(match_string)
    end

    text.scan(/([0-9]{3})\.([0-9]+)[^0-9a-z]/) do |subsection, subsubsection_root|
      @rules[subsection.to_i].each_key do |subsubsection| 
        subsubsection_prefix = zero_pad_if_needed(subsubsection_root)
        if subsubsection.start_with?(subsubsection_prefix)
          match_string = "#{subsection}.#{subsubsection}"
          matches << match_string unless matches.include?(match_string)
        end
      end
    end

    matches
  end
  
  
  def extract_glossary_rule_references
    @glossary_rules_references = {}
    @glossary.each do |term, definition|
      references = find_references_in(definition)
      references.each do |rule|
        @glossary_rules_references[term] ||= []
        @glossary_rules_references[term] << rule
      end
    end
  end
  
  
  def extract_inter_rule_references
    @inter_rules_references = {}
    rules.each do |subsection, subsection_data|
      subsection_data.each do |clause, body|
        references = find_references_in(body)
        name = "#{subsection}.#{clause}"
        references.each do |rule|
          @inter_rules_references[name] ||= []
          @inter_rules_references[name] << rule
        end
      end
    end
  end
  
  
  def extract_credits
    contents_end = @data.find_index {|line| line.start_with?("Customer Service")} + 1
    glossary_start = @data[contents_end..-1].find_index {|line| line.strip == "Glossary"} + 1 + contents_end
    credits_start = @data[glossary_start..-1].find_index {|line| line.strip == "Credits"} + 1 + glossary_start
    credits_end = @data[credits_start..-1].find_index {|line| line.strip.start_with?("Customer Service")} - 1 + credits_start
    @credits = @data[credits_start..credits_end].map {|l| l.strip}.join("\n")
  end


  def extract_customer_service
    contents_end = @data.find_index {|line| line.start_with?("Customer Service")} + 1
    glossary_start = @data[contents_end..-1].find_index {|line| line.strip == "Glossary"} + 1 + contents_end
    credits_start = @data[glossary_start..-1].find_index {|line| line.strip == "Credits"} + 1 + glossary_start
    cust_srv_start = @data[credits_start..-1].find_index {|line| line.strip.start_with?("Customer Service")} + 1 + credits_start
    @customer_service = @data[cust_srv_start..-1].map {|l| l.strip}.join("\n")

    @customer_service = ""
    buffer = ""
    @data[cust_srv_start..-1].map{|l|l.strip.gsub(/[<>]/, '')}.each do |line|
      if line.empty?
        @customer_service << "#{buffer}\n"
        buffer = ""
      else
        buffer << "#{line}<br/>"
      end
    end
    @customer_service << buffer unless buffer.empty?
  end
  
  def cleanup(term)
    if term =~ /^\W*([A-Za-z]+)\W*$/
      $1.downcase
    else
      term
    end
  end
  
  def get_terms_from(text)
    (text.split.map {|t| cleanup(t)}).select {|term| term.length > 3}
  end
  
  def add_to_index_terms(text)
    get_terms_from(text).each {|k| @index_terms << k}
  end
  
  def find_terms_in_contents(tree)
    if tree.has_key?(:text)
#      puts "Extracting terms from #{tree[:text]}"
      add_to_index_terms(tree[:text])
    end
    tree.each do |key, subtree| 
      find_terms_in_contents(subtree) unless key == :text
    end
  end
  
  def load_index_terms
    @index_terms = Set.new
    @glossary.keys.each {|key| add_to_index_terms(key)}
    
    @contents.each {|entry| find_terms_in_contents(entry)}

    if File.exists?("extra_index_terms.txt")
      lines = File.open("extra_index_terms.txt", "r") {|f| f.readlines}
      lines.each {|line| add_to_index_terms(line)}
    end
  end
  
  def index_terms_in(text)
#    puts "text: #{text}"
    @index_terms.select {|term| text.downcase.include?(term)}
  end
  
  def make_index_entry(term, key_1, key_2)
    @index[term] ||= []
    @index[term] << [key_1, key_2]
  end
  
  def find_terms_in_glossary
    @glossary.each do |key, definition|
      index_terms_in(definition).each do |term|
        make_index_entry(term, "glossary", key)
      end
    end
  end
  
  def find_terms_in_rules
    @rules.each do |subsection, subsection_contents|
      subsection_contents.each do |subsubsection, rule|
        index_terms_in(rule).each do |term|
          make_index_entry(term, subsection, subsubsection)
        end
      end
    end
  end
  
  def process_index
    @index = {}
    load_index_terms
#    puts @index_terms.first
    find_terms_in_glossary
    find_terms_in_rules
  end

end


def print_hash(indent, h)
  h.to_a.each do |k, v|
    (1..indent).each {|i| print " "}
    puts "#{k}"
    if v.kind_of?(Hash)
      print_hash(indent + 1, v)
    else
       (1..indent+1).each {|i| print " "}
      puts "#{v}"
    end
  end
end



reader = Reader.new(ARGV.first)
reader.extract_intro
reader.extract_contents
reader.extract_keyword_actions
reader.extract_keyword_abilities
reader.extract_glossary
reader.extract_rules
reader.extract_glossary_rule_references
reader.extract_inter_rule_references
reader.extract_credits
reader.extract_customer_service

reader.process_index

emitter = Emitter.new
emitter.emit_contents(reader.contents)
emitter.emit_rules(reader.rules)
emitter.emit_glossary(reader.glossary)
emitter.emit_extras(reader.intro, reader.credits, reader.customer_service)
emitter.emit_glossary_rule_references(reader.glossary_rules_references, reader.rules)
emitter.emit_inter_rule_references(reader.inter_rules_references, reader.rules)
emitter.emit_index(reader.index)
emitter.emit_indicies

#reader.index.keys.sort.each {|k| puts k}


