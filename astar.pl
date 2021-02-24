% load common file for predicates, facts and rules used by both algoruthms
:- ['common.pl'].

% to reset facts, on each knowledge base load.
:- abolish(s/3).
:- abolish(answer/1).

% to indicate facts that will change dynamically.
:- dynamic(s/3).
:- dynamic(answer/1).

% constructs the knowledge base, i.e., builds the graph edges s(from, to, length) from the given map.
construct_kb :-
    location(A, B), location(C, D),
    distance(location(A, B), location(C, D), 1), \+ covid_zone(location(A, B)), \+ covid_zone(location(C, D)),
    assert(s(location(A, B), location(C, D), 1)).

% A* interface for user predicate, get the heruistic and calls the internal utility
astar(Start, End, _, Tmp):-
    heruistic(Start, End, H),
    astar_util([(H, H, 0, [Start])], End, _, Tmp).

% A* internal utility (base case, path constructed)
astar_util([(_, _, Tmp, [End|R])|_], End, [End|R], Tmp):-
    % write('Shortest path: '),
    % write([End|R]),
    assert(answer([End|R])).

% A* internal utility (recursive routine)
astar_util([(_, _, P, [X|R1])|R2], End, C, Tmp):-
    findall(
        (Sum, H1, NP, [Z,X|R1]),
        (s(X, Z, 1), not(member(Z, R1)), NP is P+1, heruistic(Z, End, H1), Sum is H1+NP),
        L
    ),
    append(R2, L, R3),
    sort(R3, R4),
    astar_util(R4, End, C, Tmp).

% uses diagonal distance routine, since the player can move in 8 directions.
heruistic(L1, L2, Her):- 
    distance(L1, L2, Her).


% Hard-coded maps for custom testing (check report for visualization)
% TO USE: uncomment the map lines and comment the first line 'get_random_map' in predicate 'start_astar'

% home(location(1,1)).
% covid(location(4,1)).
% covid(location(1,6)).
% protection1(location(4,4)).
% protection2(location(7,7)).

% home(location(8,8)).
% covid(location(7,3)).
% covid(location(7,6)).
% protection1(location(0,6)).
% protection2(location(0,7)).

% home(location(1, 7)).
% covid(location(1, 5)).
% covid(location(3, 7)).
% protection1(location(1, 0)).
% protection2(location(8, 8)).

% home(location(8, 5)).
% covid(location(6, 5)).
% covid(location(8, 3)).
% protection1(location(3, 5)).
% protection2(location(8, 8)).

% home(location(1, 7)).
% covid(location(1, 5)).
% covid(location(3, 7)).
% protection1(location(0, 7)).
% protection2(location(0, 8)).

% gets a generated rendom map, applies algorithm, and write results
start_astar :-
    get_random_map,
    home(H),
    findall(_, construct_kb, _),
    (
        (
            once(astar(location(8, 0), H, _, _)),
            answer(Path1),
            retract(answer(Path1)),
            length(Path1, Answer1)
        ); true
    ), % write(Answer1),nl,
    (
        (
            protection1(P1),
            once(astar(location(8, 0), P1, _, _)),
            answer(Path2_tmp),
            retract(answer(Path2_tmp)),
            gen_path(Path2_tmp, Path2),
            length(Path2, Answer2)
        ); true
    ), % write(Answer2),nl,
    (
        (
            protection2(P2),
            once(astar(location(8, 0), P2, _, _)),
            answer(Path3_tmp),
            retract(answer(Path3_tmp)),
            gen_path(Path3_tmp, Path3),
            length(Path3, Answer3)
        ); true
    ), %write(Answer3),nl,
    Spl is min(min(Answer1, Answer2), Answer3) - 1,
    reverse(Path1, Path1_r),
    reverse(Path2, Path2_r),
    reverse(Path3, Path3_r),
    write("Shortest path: "),
    (
        (Answer1-1 =:= Spl -> write(Path1_r); false);
        (Answer2-1 =:= Spl -> write(Path2_r); false);
        (Answer3-1 =:= Spl -> write(Path3_r); false)
    ),
    nl, write("Shortest path length: "), write(Spl), nl.

% starting point: after loading the knowledge base, just write 'test_as' and see the magic!
test_as :-
    ['astar.pl'],
    time(once(start_astar)).