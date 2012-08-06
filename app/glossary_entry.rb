class GlossaryEntry

  attr_accessor :term, :body, :section_number

  
  def self.empty_entry
    GlossaryEntry.new('','')
  end


  def initialize(the_term, the_body)
    @term = the_term
    @body = the_body
  end


  def name
    @term
  end

end
