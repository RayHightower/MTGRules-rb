class RuleClause

  attr_accessor :subsection, :subsubsection, :body

  def initialize(the_subsection, the_subsubsection, the_body)
    @subsection = the_subsection
    @subsubsection = the_subsubsection
    @body = the_body
  end

end
