class ContentsEntry

	attr_accessor :section, :subsection, :subsubsection, :text, :children


	def initialize(the_section, the_subsection, the_subsubsection, the_text)
		@section = the_section
		@subsection = the_subsection
		@subsubsection = the_subsubsection
		@text = the_text
    @children = []
	end


  def <<(child)
    @children << child
  end

	def size
		@children.size
	end


  def [](index)
    @children[index]
  end


  def has_children?
    !@children.empty?
  end

end