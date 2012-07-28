describe "The database" do
	
	before do
		@db = Database.open('test.dat')
	end


	after do
		@db.close
	end


  it 'can open an sqlite connection' do
    @db.should.be.open
  end


  it 'can close the connection' do
    @db.close
    @db.should.not.be.open
  end


  describe 'when loading contents' do
  
    before do
      @contents = @db.load_contents
    end


  	it 'can fetch the top level contents' do
  		@contents[0].section.should == 0
  		@contents[0].text.should == 'Section 0'
      @contents[1].section.should == 1
      @contents[1].text.should == 'Section 1'
      @contents[2].section.should == 2
      @contents[2].text.should == 'Section 2'
    end
	

    it 'can fetch empty subsection contents' do
      @contents[0].size.should == 0
    end

    it 'can fetch subsections with no subsubsections' do
      @contents[1].size.should == 2
      @contents[1][0].size.should == 0
      @contents[1][1].size.should == 0
    end


    it 'can fetch subsections with subsubsections' do
      @contents[2].size.should == 2

      @contents[2][0].section.should == 2
      @contents[2][0].subsection.should == 200
      @contents[2][0].text.should == 'Subsection 200'
      @contents[2][0].size.should == 0

      @contents[2][1].section.should == 2
      @contents[2][1].subsection.should == 201
      @contents[2][1].text.should == 'Subsection 201'
      @contents[2][1].size.should == 2
    end
  

    it 'can fetch subsubsections' do
      @contents[2][1][0].section.should == 2
      @contents[2][1][0].subsection.should == 201
      @contents[2][1][0].subsubsection.should == 2
      @contents[2][1][0].text.should == 'Subsection 201-2'
      @contents[2][1][0].size.should == 0

      @contents[2][1][1].section.should == 2
      @contents[2][1][1].subsection.should == 201
      @contents[2][1][1].subsubsection.should == 3
      @contents[2][1][1].text.should == 'Subsection 201-3'
      @contents[2][1][1].size.should == 0
    end
  
  end


  describe 'when loading extra information' do

    it 'returns empty string for a missing key' do
      @db.get_extra_info('missing key').should == ''
    end    


    it 'returns the associated text for a present key' do
      @db.get_extra_info('key 1').should == 'text 1'
      @db.get_extra_info('key 2').should == 'text 2'
    end


    it 'returns first text for multiple occurances of the key' do
      @db.get_extra_info('multi key').should == "text 3a"
    end

  end


  describe 'when loading the glossary' do

    it 'can load all entries' do
      @glossary = @db.get_glossary
      
      @glossary.size.should == 3

      @glossary['term 1'].body.should == 'definition 1'
      @glossary['term 2'].body.should == 'definition 2'
      @glossary['term 3'].body.should == 'definition 3'
    end


    it 'can load specific entries' do
      @db.get_glossary_definition_for_term('term 1').body.should == 'definition 1'
      @db.get_glossary_definition_for_term('term 2').body.should == 'definition 2'
      @db.get_glossary_definition_for_term('term 3').body.should == 'definition 3'
    end
  

    it 'returns an empty entry for a non-existant term' do
      @db.get_glossary_definition_for_term('term 4').body.should == ''
    end

  end


  describe 'when loading rules' do

    it 'can fetch the rules for a subsection' do
      rules = @db.get_rules_for_subsection(100)

      rules.size.should == 2

      rules[0].subsection.should == 100
      rules[0].subsubsection.should == '01'
      rules[0].body.should == 'Rule 1'

      rules[1].subsection.should == 100
      rules[1].subsubsection.should == '02'
      rules[1].body.should == 'Rule 2'
    end


    it 'can fetch the rule for a specifc subsection/clause' do
      rule = @db.get_rule_for_subsection(101, and_subsubsection: '01a')
      rule.subsection.should == 101
      rule.subsubsection.should == '01a'
      rule.body.should == 'Rule 3'
    end


    it 'can fetch all rules for a general subsubsection' do
      rules = @db.get_rules_for_subsection(101, and_subsubsection: '01')

      rules.size.should == 2

      rules[0].subsection.should == 101
      rules[0].subsubsection.should == '01a'
      rules[0].body.should == 'Rule 3'

      rules[1].subsection.should == 101
      rules[1].subsubsection.should == '01b'
      rules[1].body.should == 'Rule 4'
    end

  end


  describe 'when loading glossary references' do

    it 'returns an empty collection for a non-existant term' do
      @db.get_rules_referenced_by_glossary_term('Bad Term').should.be.empty
    end


    it 'can fetch one term' do
      rules = @db.get_rules_referenced_by_glossary_term('Term 1')

      rules.size.should == 3

      rules[0].subsection.should == 701
      rules[0].subsubsection.should == '23'
      rules[0].body.should == 'Abandon'

      rules[1].subsection.should == 701
      rules[1].subsubsection.should == '23a'
      rules[1].body.should == 'Rule 1'

      rules[2].subsection.should == 701
      rules[2].subsubsection.should == '23b'
      rules[2].body.should == 'Rule 2'
    end


    it 'can fetch a different term' do
      rules = @db.get_rules_referenced_by_glossary_term('Term 2')

      rules.size.should == 4

      rules[0].subsection.should == 600
      rules[0].subsubsection.should == ''
      rules[0].body.should == 'Title'

      rules[1].subsection.should == 601
      rules[1].subsubsection.should == ''
      rules[1].body.should == 'Subtitle'

      rules[2].subsection.should == 601
      rules[2].subsubsection.should == '01'
      rules[2].body.should == 'Rule 3'

      rules[3].subsection.should == 601
      rules[3].subsubsection.should == '01a'
      rules[3].body.should == 'Rule 4'
    end

  end


  describe 'when loading rule references' do

    it 'returns an empty collection for a non-existant clause' do
      @db.get_rules_referenced_by_rule('Bad Clause').should.be.empty
    end


    it 'can fetch a rule' do
      rules = @db.get_rules_referenced_by_rule('100.01b')

      rules.size.should == 3

      rules[0].subsection.should == 800
      rules[0].subsubsection.should == ''
      rules[0].body.should == 'General'

      rules[1].subsection.should == 800
      rules[1].subsubsection.should == '01'
      rules[1].body.should == 'Rule 1'

      rules[2].subsection.should == 800
      rules[2].subsubsection.should == '02'
      rules[2].body.should == 'Rule 2'
    end


    it 'can fetch a different rule' do
      rules = @db.get_rules_referenced_by_rule('100.03')

      rules.size.should == 5

      rules[0].subsection.should == 900
      rules[0].subsubsection.should == ''
      rules[0].body.should == 'General'

      rules[1].subsection.should == 900
      rules[1].subsubsection.should == '01'
      rules[1].body.should == 'Rule 3'

      rules[2].subsection.should == 900
      rules[2].subsubsection.should == '02'
      rules[2].body.should == 'Rule 4'

      rules[3].subsection.should == 901
      rules[3].subsubsection.should == ''
      rules[3].body.should == 'Planechase'

      rules[4].subsection.should == 901
      rules[4].subsubsection.should == '01'
      rules[4].body.should == 'Rule 5'
    end

  end


  describe 'when searching' do

    it 'returns an empty collection when nothing is found' do
      @db.search_for("Bad Term").should.be.empty
    end


    it 'should fetch a term' do
      references = @db.search_for('abandon')

      references.size.should == 2

      references[0].should.be.kind_of(RuleClause)
      references[0].subsection.should == 100
      references[0].subsubsection.should == '01'
      references[0].body.should == 'Rule 1'

      references[1].should.be.kind_of(GlossaryEntry)
      references[1].term.should == 'term 1'
      references[1].body.should == 'definition 1'
    end


  end

end
