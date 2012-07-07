require 'rubygems'
require 'pdf/reader'


class TournamentRules

  attr :effective_date
  attr :contents
  attr :body
  attr_reader :lines
  
  def initialize(filename)
    filepath = File.expand_path(filename)
    
    @lines = PDF::Reader.open(filepath) { |reader| reader.pages.collect{ |page| page.text.split("\n") }}.flatten
  end

  def remove_page_breaks
    last_line_was_page_number = false
    @lines.reject! do |l| 
      if l =~ /^[0-9]+ $/
        last_line_was_page_number = true
      elsif l.strip.empty? && last_line_was_page_number
        last_line_was_page_number = false
        true
      else
        last_line_was_page_number = false
      end
    end
  end

  def extract_effective_date
    @lines.shift
    @effective_date = Date.parse(@lines.shift)
  end

  def parse_content_line(line)
    if line =~ /^( *)(([0-9]+).([0-9]*) +)?([^\.]+)\.\.+[0-9]+/
      [$3, $4, $5.strip]
    else
      [nil, nil, nil]
    end
  end

  def drop_upto(item)
    while @lines.shift != item
    end
  end
  
  def extract_contents
    content_lines = @lines.select {|l| l =~ /^.*\.\.\.+[0-9]+/}
    drop_upto(content_lines.last)
    @contents = {}
    appendix_letter = nil
    appendix_subsection = nil
    section = nil
    subsection = nil
    title = nil
    
    content_lines.each do |line|
      section, subsection, title = parse_content_line(line)
      section = '0' if section.nil? || section.empty?
      subsection = "" if subsection.nil?

      if title =~ /^Appendix ([A-Z]).(.*)$/
        appendix_letter = $1
        appendix_subsection = 1
        section = appendix_letter
        subsection = ""
        title = $2
      elsif section == "0" && !appendix_letter.nil?
        section = appendix_letter
        subsection = appendix_subsection.to_s
        appendix_subsection += 1
      end
      
      @contents[section] ||= {}
      if subsection.empty?
        @contents[section][:title] = title
      else
        @contents[section][subsection] = title
      end
    end
  end

  def is_section_header(line)
    line == "Introduction" ||
      line =~ /^( *)([0-9]+)(.([0-9]+))? +([^\.]+)$/ ||
      line =~ /^Appendix ([A-Z]).(.*)$/ ||
      (@in_appendix && line =~ /^[A-Za-z ]+$/)
  end

  def parse_section_line(line)
    if line =~ /^( *)([0-9]+)(.([0-9]*))? +([^\.]+)/
      return [nil, nil] if $4.nil? || $4.empty?
      puts "Main section: #{$2} - #{$4} : #{$5}"
      [$2, $4]
    elsif line.strip == "Introduction"
      ["0", "0"]
    elsif line =~ /^Appendix ([A-Z]).(.*)$/
      @in_appendix = true
      @major_section = $1
      @minor_section = 0
      [nil, nil]
    else
      @minor_section += 1
      puts "Appendix section: #{@major_section} - #{@minor_section}"
      [@major_section, @minor_section.to_s]
    end
  end

  def extract_sections
    @in_appendix = false
    @body = {}
    section_body = []
    @lines.each do |line|
      if is_section_header(line)
        section, subsection = parse_section_line(line)
        unless section.nil? || subsection.nil?
          @body[section] ||= {}
          @body[section][subsection] = section_body.join(' ')
        end
      else
        section_body << line
      end
    end
  end
  
  def extract_rules
    remove_page_breaks
    extract_effective_date
    extract_contents
    nil
  end
  
end

#  rules = TournamentRules.new(ARGV.first)
def go
  puts "Loading rules..."
  rules = TournamentRules.new('Magic_The_Gathering_Tournament_Rules_PDF2.pdf')
  puts "Extracting rules..."
  rules.extract_rules
  rules
end

#  puts rules.effective_date
