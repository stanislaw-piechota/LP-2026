:- use_module(library(clpfd)).
:- [tests].

% snake(RowHints, ColHints, Grid, Solution)

% snake()
snake(RowHints, ColHints, Grid, Solution) :- 
                Rows=Grid,
                zipWithRow(RowHints, Rows, RowConstraint),
                transpose(RowConstraint, Columns), 
                zipWithRow(ColHints, Columns, ColConstraint),
                transpose(ColConstraint, Solution),
                has_unique_path(Solution),
                check_adjacency_grid(Solution).

zipWithRow(L1, L2, OutList) :-
                maplist([C, Inp, Out]>>row(C, Inp, Out), L1, L2, OutList).

row(-1, Inp, Out) :-
                empty(Inp, Out),
                length(Inp, Length),
                count_snake(Out, Count), Count in 0..Length.
row(C, Inp, Out) :- 
                empty(Inp, Out),
                count_snake(Out, Count), Count #= C.

empty([], []).
empty([H|T], [0|OutList]) :- H #= -1, empty(T, OutList).
empty([H|T], [2|OutList]) :- H #= -1, empty(T, OutList).
empty([H|T], [H|OutList]) :- H in 0..2, empty(T, OutList).

count_snake([], 0).
count_snake([X|L], C2) :- X in 1..2, count_snake(L, C), C2 is C+1.
count_snake([X|L], C) :- X in -1..0, count_snake(L, C).

check_adjacency_grid([R1, R2]) :- check_adjacency_row(R1, R2).
check_adjacency_grid([R1, R2 | Rest]) :- check_adjacency_row(R1, R2), check_adjacency_grid([R2 | Rest]).

check_adjacency_row([E1, E2], [E3, E4]) :- adjacent([E1, E2], [E3, E4]).
check_adjacency_row([E1, E2 | R1], [E3, E4 | R2]) :- adjacent([E1, E2], [E3, E4]), check_adjacency_row([E2 | R1], [E4 | R2]).

adjacent([2, 2], [0, 1]).
adjacent([1, 2], [0, 2]).
adjacent([1, 2], [0, 1]).
adjacent([2, 2], [0, 2]).
adjacent([2, 1], [2, 0]).
adjacent([2, 2], [1, 0]).
adjacent([2, 1], [1, 0]).
adjacent([2, 2], [2, 0]).
adjacent([1, 0], [2, 2]).
adjacent([2, 0], [2, 1]).
adjacent([1, 0], [2, 1]).
adjacent([2, 0], [2, 2]).
adjacent([0, 2], [1, 2]).
adjacent([0, 1], [2, 2]).
adjacent([0, 1], [1, 2]).
adjacent([0, 2], [2, 2]).
adjacent([0, 0], [X, Y]) :- [X, Y] ins 1..2.
adjacent([X, Y], [0, 0]) :- [X, Y] ins 1..2.
adjacent([X, 0], [Y, 0]) :- [X, Y] ins 1..2.
adjacent([0, X], [0, Y]) :- [X, Y] ins 1..2.
adjacent([X, 0], [0, 0]) :- X in 1..2.
adjacent([0, X], [0, 0]) :- X in 1..2.
adjacent([0, 0], [X, 0]) :- X in 1..2.
adjacent([0, 0], [0, X]) :- X in 1..2.
adjacent([0, 0], [0, 0]).

% check_neighbors_block([E1, E2], [E3, E4]) :- adjacent([E1, E2], [E3, E4]).
% check_neighbors_block([E1, E2, E3], [E4, E5, E6], [E7, E8, E9]) :- 
%                     adjacent([E1, E2], [E4, E5]),
%                     adjacent([E2, E3], [E5, E6]),
%                     adjacent([E4, E5], [E7, E8]),
%                     adjacent([E5, E6], [E8, E9]).
% check_neighbors_block([E1, E2, E3 | R1], [E4, E5, E6 | R2], [E7, E8, E9 | R3]) :- 
%                     adjacent([E1, E2], [E4, E5]),
%                     adjacent([E2, E3], [E5, E6]),
%                     adjacent([E4, E5], [E7, E8]),
%                     adjacent([E5, E6], [E8, E9]),
%                     check_neighbors_block([E2, E3 | R1], [E5, E6 | R2], [E8, E9 | R3]).

% neighbors([0, 2, 0], [0, 2, 0], [0, 0, 0]).
% neighbors([0, 2, 0], [0, 2, 0], [0, 2, 0]).
% neighbors([0, 2, 0], [0, 2, 0], [0, 1, 0]).
% neighbors([0, 1, 0], [0, 2, 0], [0, 2, 0]).
% neighbors([0, 2, 0], [0, 2, 0], [0, 2, 0]).

% top-right corner
% neighbors([1, 1], [0, 0], end).
% neighbors([1, 0], [1, 0], end).
% neighbors([1, 2], [0, 0], not_end).
% neighbors()
% neighbors([])
% find_head(Grid)

% trail(_, _, _, []).
% trail(I, W, H, [0|Rest]) :- I0 is I+1 trail(I0, Rest). % looking for 1
% trail(I, W, H, [1|Rest]) :- 

has_unique_path(Grid) :-
    % 1. Find the coordinates of both '1's
    find_all_coords(Grid, 1, [Start, End]),
    % 2. Find all coordinates of '2's available in the grid
    find_all_coords(Grid, 2, AllTwos),
    count_valid_moves(Start, AllTwos, End, 1),
    count_valid_moves(End, AllTwos, Start, 1),
    % 3. Trace the path from Start to End using the available 2s
    trace_path(Start, End, AllTwos).

% Trace Path: Base Case - If the End is adjacent to the Current node, we successfully reached it!
trace_path(Current, End, []) :-
    check_adjacent(Current, End).

% Trace Path: Recursive Step
trace_path(Current, End, AvailableTwos) :-
    % Find an adjacent '2' from our pool of available coordinates
    check_adjacent(Current, Next),
    member(Next, AvailableTwos),
    % IMPORTANT: Step 4 constraint check. 
    % To guarantee non-ambiguity, 'Current' must only have ONE valid legal move forward.
    % If it has more than one adjacent valid piece, the path is ambiguous (fails).
    count_valid_moves(Current, AvailableTwos, End, 1),
    
    % Remove 'Next' from the pool so we don't walk backward (prevents loops)
    select(Next, AvailableTwos, RemainingTwos),
    
    % Keep tracing from the new position
    trace_path(Next, End, RemainingTwos).

% Checks if two coordinates are orthogonally adjacent
check_adjacent((X, Y1), (X, Y2)) :- delta_one(Y1, Y2).
check_adjacent((X1, Y), (X2, Y)) :- delta_one(X1, X2).
delta_one(A, B) :- B is A + 1.
delta_one(A, B) :- B is A - 1.

% Count how many legal next steps exist from the current spot
count_valid_moves(Current, AvailableTwos, End, Count) :-
    aggregate_all(count, (
        check_adjacent(Current, Step), 
        (Step = End ; member(Step, AvailableTwos))
    ), Count).

% Find all (X, Y) coordinates matching a specific Value in the 2D Grid
find_all_coords(Grid, Value, Coords) :-
    findall((X, Y), (
        nth0(Y, Grid, Row),
        nth0(X, Row, Value)
    ), Coords).