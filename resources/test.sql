drop table contents;
create table contents('section' integer, 'subsection' integer, 'subsubsection' integer, 'text' text);
insert into contents(section, subsection, subsubsection, text) values (0, 0, 0, 'Section 0');
insert into contents(section, subsection, subsubsection, text) values (1, 0, 0, 'Section 1');
insert into contents(section, subsection, subsubsection, text) values (1, 100, 0, 'Subsection 100');
insert into contents(section, subsection, subsubsection, text) values (1, 101, 0, 'Subsection 101');
insert into contents(section, subsection, subsubsection, text) values (2, 0, 0, 'Section 2');
insert into contents(section, subsection, subsubsection, text) values (2, 200, 0, 'Subsection 200');
insert into contents(section, subsection, subsubsection, text) values (2, 201, 0, 'Subsection 201');
insert into contents(section, subsection, subsubsection, text) values (2, 201, 2, 'Subsection 201-2');
insert into contents(section, subsection, subsubsection, text) values (2, 201, 3, 'Subsection 201-3');

drop table extras;
create table extras('name' text, 'body' text);
insert into extras(name, body) values ('key 1', 'text 1');
insert into extras(name, body) values ('key 2', 'text 2');
insert into extras(name, body) values ('multi key', 'text 3a');
insert into extras(name, body) values ('multi key', 'text 3b');

drop table glossary;
create table glossary('term' text, 'definition' text);
insert into glossary(term, definition) values ('term 1', 'definition 1');
insert into glossary(term, definition) values ('term 2', 'definition 2');
insert into glossary(term, definition) values ('term 3', 'definition 3');

drop table rules;
create table rules('subsection' integer, 'subsubsection' text, 'body' text);
insert into rules(subsection, subsubsection, body) values (100, '01', 'Rule 1');
insert into rules(subsection, subsubsection, body) values (100, '02', 'Rule 2');
insert into rules(subsection, subsubsection, body) values (101, '01a', 'Rule 3');
insert into rules(subsection, subsubsection, body) values (101, '01b', 'Rule 4');

drop table glossaryrefs;
create table glossaryrefs(term text, subsection integer, subsubsection text, body text);
insert into glossaryrefs(term, subsection, subsubsection, body) values ('Term 1', 701, '23', 'Abandon');
insert into glossaryrefs(term, subsection, subsubsection, body) values ('Term 1', 701, '23a', 'Rule 1');
insert into glossaryrefs(term, subsection, subsubsection, body) values ('Term 1', 701, '23b', 'Rule 2');
insert into glossaryrefs(term, subsection, subsubsection, body) values ('Term 2', 600, '', 'Title');
insert into glossaryrefs(term, subsection, subsubsection, body) values ('Term 2', 601, '', 'Subtitle');
insert into glossaryrefs(term, subsection, subsubsection, body) values ('Term 2', 601, '01', 'Rule 3');
insert into glossaryrefs(term, subsection, subsubsection, body) values ('Term 2', 601, '01a', 'Rule 4');

drop table rulerefs;
create table rulerefs(rule text, subsection integer, subsubsection text, body text);
insert into rulerefs(rule, subsection, subsubsection, body) values ('100.01b', 800, '', 'General');
insert into rulerefs(rule, subsection, subsubsection, body) values ('100.01b', 800, '01', 'Rule 1');
insert into rulerefs(rule, subsection, subsubsection, body) values ('100.01b', 800, '02', 'Rule 2');
insert into rulerefs(rule, subsection, subsubsection, body) values ('100.03', 900, '', 'General');
insert into rulerefs(rule, subsection, subsubsection, body) values ('100.03', 900, '01', 'Rule 3');
insert into rulerefs(rule, subsection, subsubsection, body) values ('100.03', 900, '02', 'Rule 4');
insert into rulerefs(rule, subsection, subsubsection, body) values ('100.03', 901, '', 'Planechase');
insert into rulerefs(rule, subsection, subsubsection, body) values ('100.03', 901, '01', 'Rule 5');

drop table searchindex;
create table searchindex(searchterm text, key1 text, key2 text);
insert into searchindex(searchterm, key1, key2) values ('abandon', 'glossary', 'term 1');
insert into searchindex(searchterm, key1, key2) values ('abandon', '100', '01');
insert into searchindex(searchterm, key1, key2) values ('turn', 'glossary', 'term 2');
insert into searchindex(searchterm, key1, key2) values ('turn', '101', '01a');
insert into searchindex(searchterm, key1, key2) values ('turn', '101', '01b');

create index glossaryrefsbyterm on glossaryrefs(term asc);
create index rulerefsbyrule on rulerefs(rule asc);
create index searchindexbyterm on searchindex(searchterm asc);
