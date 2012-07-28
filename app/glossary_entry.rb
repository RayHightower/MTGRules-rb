class GlossaryEntry

  attr_accessor :term, :body

  def self.empty_entry
  	GlossaryEntry.new('','')
  end


  def initialize(the_term, the_body)
    @term = the_term
    @body = the_body
  end

end
