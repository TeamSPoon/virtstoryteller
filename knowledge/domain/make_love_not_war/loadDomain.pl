% Only executable if load.pl was loaded
:- ensure_loaded('../../prolog/load.pl').

% Define Namespaces for domain
:- rdf_db:rdf_register_ns(love, 'http://www.owl-ontologies.com/StoryWorldSettings/MakeLoveNotWar.owl#').
:- rdf_db:rdf_load('ontology/MakeLoveNotWar.owl').
:- rdf_db:rdf_load('setting/park.ttl').

% Load schemas into schema management module
:- consult(schemas:'schemas/schema.pl').

% TODO: bring episode and suggestion clauses under in their respective modules too.
:- consult(schemas:'threads/threads.pl').
:- consult('suggestions/suggestion.pl').
