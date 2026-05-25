:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- [tests].

% Main Entry Point
snake(RowHints, ColHints, Grid, Solution) :-
    map_grid(Grid, Solution),

    maplist(apply_hint, RowHints, Solution),
    transpose(Solution, Columns),
    maplist(apply_hint, ColHints, Columns),

    % Extract 2x2 blocks safely and apply pure mathematical adjacency constraints
    blocks_in_grid(Solution, Blocks, []),
    valid_tuples(Tuples),
    tuples_in(Blocks, Tuples),

    append(Solution, FlatGrid),
    labeling([ffc], FlatGrid),

    % Double-lock: once/1 ensures we don't backtrack through pathing
    once(has_unique_path(Solution)).

% --- 1. Safe Block Extraction (Notice the Cuts `!`) ---
blocks_in_grid([R1, R2 | Rows], Blocks, Tail) :- !,
    blocks_in_rows(R1, R2, Blocks, Tail1),
    blocks_in_grid([R2 | Rows], Tail1, Tail).
blocks_in_grid(_, Tail, Tail).

blocks_in_rows([X1, X2 | R1], [Y1, Y2 | R2], [[X1, X2, Y1, Y2] | Blocks], Tail) :- !,
    blocks_in_rows([X2 | R1], [Y2 | R2], Blocks, Tail).
blocks_in_rows(_, _, Tail, Tail).

% --- 2. Pure Mathematical Snake Constraints ---
% Generates all valid 2x2 configurations without hardcoding
valid_tuples(Tuples) :-
    findall([A, B, C, D], valid_block([A, B, C, D]), Tuples).

valid_block([A, B, C, D]) :-
    [A, B, C, D] ins 0..2,
    
    % Reify the occupancy of each cell (1 if snake is present, 0 if empty)
    A_occ #<==> (A #> 0),
    B_occ #<==> (B #> 0),
    C_occ #<==> (C #> 0),
    D_occ #<==> (D #> 0),
    
    Sum #= A_occ + B_occ + C_occ + D_occ,
    
    % Constraint 1: Forbid 2x2 filled squares (Sum cannot be 4)
    Sum #\= 4,
    
    % Constraint 2: Forbid Diagonal Touching 
    % A diagonal touch occurs if there are exactly 2 pieces (Sum=2) AND 
    % they sit on a diagonal (A_occ == D_occ). We strictly forbid this combination.
    #\ (Sum #= 2 #/\ A_occ #= D_occ),
    
    label([A, B, C, D]).

% --- 3. Domain Setup ---
map_grid([], []).
map_grid([Row|Rows], [SolRow|SolRows]) :-
    map_row(Row, SolRow),
    map_grid(Rows, SolRows).

map_row([], []).
map_row([-1|T], [V|SolT]) :- !,
    V in 0 \/ 2,
    map_row(T, SolT).
map_row([H|T], [H|SolT]) :-
    map_row(T, SolT).

% --- 4. Hint Constraints ---
apply_hint(-1, _Vars) :- !.
apply_hint(C, Vars) :-
    maplist(is_snake_piece, Vars, Bs),
    sum(Bs, #=, C).

is_snake_piece(V, B) :- V #> 0 #<==> B.

% --- 5. Graph Verification (Unique Path) ---
has_unique_path(Grid) :-
    find_all_coords(Grid, 1, [Start, End]),
    find_all_coords(Grid, 2, AllTwos),
    count_valid_moves(Start, AllTwos, End, 1),
    count_valid_moves(End, AllTwos, Start, 1),
    trace_path(Start, End, AllTwos).

trace_path(Current, End, []) :- !,
    check_adjacent(Current, End).

trace_path(Current, End, AvailableTwos) :-
    check_adjacent(Current, Next),
    member(Next, AvailableTwos),
    count_valid_moves(Current, AvailableTwos, End, 1),
    select(Next, AvailableTwos, RemainingTwos),
    trace_path(Next, End, RemainingTwos).

check_adjacent((X, Y1), (X, Y2)) :- delta_one(Y1, Y2).
check_adjacent((X1, Y), (X2, Y)) :- delta_one(X1, X2).
delta_one(A, B) :- B is A + 1.
delta_one(A, B) :- B is A - 1.

count_valid_moves(Current, AvailableTwos, End, Count) :-
    aggregate_all(count, (
        check_adjacent(Current, Step), 
        (Step = End ; member(Step, AvailableTwos))
    ), Count).

find_all_coords(Grid, Value, Coords) :-
    findall((X, Y), (
        nth0(Y, Grid, Row),
        nth0(X, Row, Value)
    ), Coords).