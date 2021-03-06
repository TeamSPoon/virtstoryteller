% ---------------------------------------------------------------------------------
% Copyright (C) 2008 Human Media Interaction - University of Twente
%  
% This file is part of The Virtual Storyteller.
% 
% The Virtual Storyteller is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% The Virtual Storyteller is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with The Virtual Storyteller. If not, see <http://www.gnu.org/licenses/>.
% ---------------------------------------------------------------------------------

/*  $Id: rdf_base.pl,v 1.1 2006/10/27 08:48:57 kruizingaee Exp $

    Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        wielemak@science.uva.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 1985-2005, University of Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/


:- module(rdf_base,
	  [ load_base_ontology/1,	% +Id
	    load_base_ontology/2,	% +Id, +Options
	    load_required_base_ontologies/0,
	    current_base_ontology/1,	% -Id
	    required_base_ontology/1,	% -Id
	    register_default_ns/2	% +File, +List
	  ]).

:- use_module(library(broadcast)).
:- use_module(semweb(rdf_db)).
:- use_module(semweb(rdfs)).
:- use_module(semweb(rdf_edit)).
:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(library(option)).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
This file defines commonly used namespaces,   base ontologies. etc. Note
that the namespaces must be loaded *before*   they can be used in Prolog
source-code.

One  day  the  ontology  directories  should  be  holding  an  RDF  file
describing the directory contents and  their   dependencies.  This  is a
quick hack.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


		 /*******************************
		 *    PREDEFINED NAMESPACES	*
		 *******************************/

ns(dc,	    'http://purl.org/dc/elements/1.1/').
ns(dcterms, 'http://purl.org/dc/terms/').
ns(dctypes, 'http://purl.org/dc/dcmitype/').
ns(vra,	    'http://www.swi.psy.uva.nl/mia/vra#').
ns(foaf,    'http://xmlns.com/foaf/0.1/').
ns(aat,	    'http://www.swi.psy.uva.nl/mia/aat#').
ns(aat2004, 'http://www.getty.edu/vocabularies/aat#'). % BJW
ns(ulan,    'http://www.swi.psy.uva.nl/mia/ulan#').
ns(ulan2004,'http://www.getty.edu/vocabularies/ulan#'). % BJW
ns(wn,	    'http://www.cogsci.princeton.edu/~wn/concept#').
ns(wns,	    'http://www.cogsci.princeton.edu/~wn/schema/').
ns(paint,   'http://www.swi.psy.uva.nl/mia/painting#').
ns(subject, 'http://www.swi.psy.uva.nl/mia/subject#').
ns(ic,	    'http://www.swi.psy.uva.nl/mia/iconclass#').
ns(ghs,	    'http://www.swi.psy.uva.nl/mia/ghs#').
ns(ann,	    'http://www.swi.psy.uva.nl/mia/ann#').
ns(vin,	    'http://www.w3.org/2001/sw/WebOnt/guide-src/wine#').
ns(cyc,	    'http://www.cyc.com/cyc#').
ns(cyc03,   'http://www.cyc.com/2003/04/01/cyc#').
ns(sumo,    'http://reliant.teknowledge.com/DAML/SUMO.daml#').
ns(erc,	    'http://www.swi.psy.uva.nl/mia/cml/erc#').
ns(dolce,   'http://ontology.ip.rm.cnr.it/ontologies/DOLCE-Lite#').
ns(galen,   'http://example.org/factkb#').
ns(fam,	    'http://swi.psy.uva.nl/family#').
ns(swrl,    'http://www.w3.org/2003/11/swrl#').
ns(mesh,    'http://www.nlm.nih.gov/mesh/2004#').
ns(galen,   'http://example.org/factkb#').
ns(gcl,	    'http://www.govtalk.gov.uk/schemasstandards/gcl#').
ns(skos,    'http://www.w3.org/2004/02/skos/core#').
ns(skosm,   'http://www.w3.org/2004/02/skos/mapping#').
ns(aeneas,  'http://www.swi.psy.uva.nl/mia/aeneas#').
ns(mia2,    'http://www.swi.psy.uva.nl/mia/mia2#').
ns(thales,  'http://www.swi.psy.uva.nl/metis/thales#').
ns(poly,    'http://metis.org/ontologies/basell/poly#'). % BJW
ns(rs,	    'http://jena.hpl.hp.com/2003/03/result-set#').
ns(t20,	    'http://www.swi-prolog.org/packages/Triple20/').
ns(nci,	    'http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#').

:- forall(ns(Alias, URI),
	  catch(rdf_register_ns(Alias, URI, [keep(true)]), E,
		print_message(error, E))).

%	register_default_ns(File, NS=URL)
%	
%	Register a namespace as encounted in   the  namespace list of an
%	RDF document. We only register if  both the abbreviation and URL
%	are not already known. Is there a   better  way? This code could
%	also do checks on the consistency   of  RDF and other well-known
%	namespaces.

register_default_ns(_, []) :- !.
register_default_ns(File, NSList) :-
	register_def_ns(NSList, File).

register_def_ns(X, _) :-
	var(X), !,
	throw(error(instantiation_error, _)).
register_def_ns([], _) :- !.
register_def_ns([NS=URL|T], File) :- !,
	register_def_ns(NS=URL, File),
	register_def_ns(T, File).
register_def_ns([]=_, _) :- !.		% xmlns= (overall default)
register_def_ns(NS=URL, File) :-
	(   rdf_db:ns(NS, URL)
	->  true
	;   rdf_db:ns(NS, _)
	->  true			% redefined abbreviation
	;   rdf_db:ns(_, URL)
	->  true			% redefined URL
	;   rdf_register_ns(NS, URL)
	),
					% register non-standard namespaces
	(   rdf_file(_, NS, _)
	->  true
	;   NS == rdf
	->  true
	;   broadcast(rdf_set_default_ns(File, NS))
	).


		 /*******************************
		 *	  BASIC ONTOLOGIES	*
		 *******************************/

%	load_base_ontology(+Identifier)

load_base_ontology(Category) :-
	load_base_ontology(Category, []).

load_base_ontology(Category, Options) :-
	findall(load_base(File, Options),
		expand_category(Category, File),
		Goals0),
	list_to_set(Goals0, Goals),
	maplist(call, Goals).

load_base(File:NS, Options) :- !,
	absolute_file_name(File,
			   [ access(read),
			     extensions([rdf,rdfs,owl,''])
			   ], Path),
	load_base(Path, Options),
	broadcast(rdf_set_default_ns(Path, NS)).
load_base(File, Options) :- 
	absolute_file_name(File,
			   [ access(read),
			     extensions([rdf,rdfs,owl,''])
			   ], Path),
	(   option(transactions(false), Options, true)
	->  rdf_load(Path)
	;   rdfe_load(Path),
	    rdfe_set_file_property(Path, access(ro))
	).

%	current_base_ontology(-Identifier)
%	
%	Enemate defined base-ontologies

current_base_ontology(Id) :-
	findall(X, (rdf_file(X, _);requires(X, _)), Xs),
	sort(Xs, List),
	member(Id, List),
	forall(expand_category(Id, FileSpec:_NS), 	% check existence
	       absolute_file_name(FileSpec,
				  [ access(read),
				    file_errors(fail)
				  ],
				  _File)).


rdf_file(Id, File) :-
	rdf_file(Id, _DefNS, File).

%	rdf_file(+Identifier, -DefNS, -File)
%	
%	Register the file that belong to a base ontology

rdf_file(rdfs,	 	 rdfs, ontology('rdfs.rdfs')).
rdf_file(owl,		 owl,  ontology('owl.owl')).
rdf_file(owlfull,        owl,  ontology('owlfull.owl')).
rdf_file(dc,	 	 dc,   ontology('dc.rdfs')).
rdf_file(dc,	 	 dc,   ontology('dcterms.rdfs')).
rdf_file(dc,	 	 dc,   ontology('dctypes.rdfs')).
rdf_file(dc,	 	 eor,  ontology('eor.rdfs')).
rdf_file(skos,		 skos, ontology('skos-core.rdfs')).
rdf_file(foaf,		 foaf, ontology('foaf.owl')).

rdf_file(t20,		 t20,  ontology('t20.rdfs')).

rdf_file(aat,		 aat,  ontology('aatmeta.rdfs')).
rdf_file(aat,		 aat,  ontology('aat.rdfs')).

rdf_file(ulan,		 ulan, ontology('ulan.rdfs')).
rdf_file(ulan,		 ulan, ontology('ulan.rdf')).

rdf_file(wn,		 wns,  ontology('wordnet-20000620.rdfs')).
rdf_file(wn,		 wn,   ontology('wordnet_glossary-20010201.rdf')).
rdf_file(wn,		 wn,   ontology('wordnet_hyponyms-20010201.rdf')).
rdf_file(wn,		 wn,   ontology('wordnet_nouns-20010201.rdf')).
rdf_file(wn,		 wn,   ontology('wordnet_similar-20010201.rdf')).
rdf_file(wnrdfs,	 wns,  ontology('wnclass.rdfs')).

rdf_file(ic,		 ic,   ontology('iconclass.rdfs')).

rdf_file(cyc,		 cyc,  ontology('cyc03.rdfs')).
rdf_file(sumo,		 sumo, ontology('sumo.rdfs')).

%	requires(+Id1, -Id2)
%	
%	Base Id1 requires base Id2.

requires(owl,	   rdfs).
requires(dc,	   rdfs).
requires(painting, owl).
requires(aat,	   rdfs).
requires(ulan,	   rdfs).
requires(wn,	   rdfs).
requires(wnrdfs,   wn).
requires(ic,	   rdfs).
requires(cyc,	   owl).
requires(sumo,	   owl).
requires(owlfull,  owl).

requires(world,	   owl).
requires(world,	   aat).
requires(world,	   ulan).
requires(world,	   wnrdfs).
requires(world,	   ic).


		 /*******************************
		 *	   REQUIRED BASES	*
		 *******************************/

%	required_base_ontology(-Base)
%	
%	Deduce the required base ontologies from expressions used in the
%	document.  This is heuristic and far from complete.
%	
%	Note we first check for  the  high   level  bases  as  this will
%	automatically include the more primitive ones.

required_base_ontology(Base) :-
	rdf_file(Base, NS, FileSpec),
	rdf_db:ns(NS, Full),
	(   referenced_predicate(P),
	    rdf_url_namespace(P, Full),
	    absolute_file_name(FileSpec, _Path, 
			       [ file_errors(fail),
				 access(read)
			       ])
	->  true
	).
required_base_ontology(Base) :-
	rdf_source(X),
	file_name_extension(_, Ext, X),
	required_by_ext(Ext, Base).

%	referenced_predicate(?P)
%	
%	Find the predicates that are referenced by the current data-set

referenced_predicate(P) :-
	rdf_current_predicate(P).
referenced_predicate(P) :-
	rdf(_, owl:onProperty, P).
referenced_predicate(P) :-
	rdf(_, rdfs:subPropertyOf, P).

required_by_ext(rdfs, rdfs).
required_by_ext(owl, owl).

%	load_required_base_ontologies/0
%	
%	Load all registered base ontologies that are referred by the
%	current set of documents.

load_required_base_ontologies :-
	load_required_base_ontologies([]).

load_required_base_ontologies(Done) :-
	setof(Base, required_base_ontology(Base), Bases),
	ord_subtract(Bases, Done, Todo),
	Todo \== [], !,
	forall(member(Base, Todo),
	       load_base_ontology(Base)),
	ord_union(Done, Todo, Done1),
	load_required_base_ontologies(Done1).
load_required_base_ontologies(_).


		 /*******************************
		 *		UTIL		*
		 *******************************/

expand_category(C, F) :-
	(   rdf_file(C, NS, File),
	    F = File:NS
	;   requires(C, R),
	    expand_category(R, F)
	).

