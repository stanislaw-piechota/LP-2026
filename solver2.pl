:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- [tests].
:- [mytests].

% Main Entry Point
snake(RowHints, ColHints, Grid, Solution) :-
    copy_grid(Grid, Solution, OccGrid),

    maplist(apply_hint, RowHints, OccGrid),
    transpose(OccGrid, OccColumns),
    maplist(apply_hint, ColHints, OccColumns),

    % Extract 2x2 blocks safely and apply pure mathematical adjacency constraints
    blocks_in_grid(Solution, Blocks, []),
    valid_tuples(Tuples),
    tuples_in(Blocks, Tuples),
    % Enforce per-cell neighbor-degree constraints to prune search early
    enforce_degrees(Solution, OccGrid),

    append(Solution, FlatGrid),
    labeling([ffc], FlatGrid),

    once(has_unique_path(Solution)).

% --- 1. Safe Block Extraction (Notice the Cuts `!`) ---
blocks_in_grid([R1, R2 | Rows], Blocks, Tail) :- !,
    blocks_in_rows(R1, R2, Blocks, Tail1),
    blocks_in_grid([R2 | Rows], Tail1, Tail).
blocks_in_grid(_, Tail, Tail).

blocks_in_rows([X1, X2 | R1], [Y1, Y2 | R2], [[X1, X2, Y1, Y2] | Blocks], Tail) :- !,
    blocks_in_rows([X2 | R1], [Y2 | R2], Blocks, Tail).
blocks_in_rows(_, _, Tail, Tail).

% --- 2. Solution blocks constraints - avoid touching ---
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
    % they sit on a diagonal (A == D) or (B == C).
    #\ (Sum #= 2 #/\ (A #= D #\/ B #= C)),
    
    label([A, B, C, D]).

% --- 3. Domain Setup ---
% Build Solution grid and Occupancy grid together from original puzzle Grid
% Solution grid - exact answers; Occupancy grid - binary indicators for snake presence (for hint application and degree enforcement)
copy_grid([], [], []).
copy_grid([Row|Rows], [SolRow|SolRows], [OccRow|OccRows]) :-
    copy_row(Row, SolRow, OccRow),
    copy_grid(Rows, SolRows, OccRows).

copy_row([], [], []).
copy_row([-1|Ts], [V|Vs], [O|Os]) :- !,
    V in 0\/2,
    V #> 0 #<==> O,
    copy_row(Ts, Vs, Os).
copy_row([H|Ts], [H|Vs], [O|Os]) :-
    O in 0..1,
    (H #> 0) #<==> O,
    copy_row(Ts, Vs, Os).

% --- 4. Hint Constraints ---
apply_hint(-1, _Vars) :- !.
apply_hint(C, OccVars) :-
    sum(OccVars, #=, C).

% --- 5. Degree enforcement ---
enforce_degrees(Grid, OccGrid) :-
    length(Grid, Rows), Rows > 0,
    nth0(0, Grid, FirstRow), length(FirstRow, Cols),
    MaxY is Rows - 1,
    MaxX is Cols - 1,
    enforce_rows(0, MaxX, MaxY, Grid, OccGrid).

enforce_rows(Y, _MaxX, MaxY, _Grid, _OccGrid) :-
    Y > MaxY, !.
enforce_rows(Y, MaxX, MaxY, Grid, OccGrid) :-
    nth0(Y, Grid, Row),
    enforce_cols(0, Row, Y, MaxX, MaxY, Grid, OccGrid),
    Y1 is Y + 1,
    enforce_rows(Y1, MaxX, MaxY, Grid, OccGrid).

enforce_cols(X, _Row, _Y, MaxX, _MaxY, _Grid, _OccGrid) :-
    X > MaxX, !.
enforce_cols(X, Row, Y, MaxX, MaxY, Grid, OccGrid) :-
    nth0(X, Row, Var),
    Var #>= 0,
    Var #=< 2,
    count_neighbors(X, Y, OccGrid, MaxX, MaxY, Count),
    Count in 0..4,
    (Var #= 1) #==> (Count #= 1),
    (Var #= 2) #==> (Count #= 2),
    X1 is X + 1,
    enforce_cols(X1, Row, Y, MaxX, MaxY, Grid, OccGrid).

neighbor_coords(X, Y, MaxX, MaxY, Neis) :-
    UpY is Y - 1,
    DownY is Y + 1,
    LeftX is X - 1,
    RightX is X + 1,
    findall((NX, NY), (
        member((NX, NY), [(X, UpY), (X, DownY), (LeftX, Y), (RightX, Y)]),
        NX >= 0,
        NY >= 0,
        NX =< MaxX,
        NY =< MaxY
    ), Neis).

neis_to_occs([], _OccGrid, []).
neis_to_occs([(NX,NY)|T], OccGrid, [O|Os]) :-
    nth0(NY, OccGrid, OccRow), nth0(NX, OccRow, O),
    neis_to_occs(T, OccGrid, Os).

count_neighbors(X, Y, OccGrid, MaxX, MaxY, Count) :-
    neighbor_coords(X, Y, MaxX, MaxY, Neis),
    neis_to_occs(Neis, OccGrid, NeOccs),
    sum(NeOccs, #=, Count).

% --- 6. Graph Verification (Unique Path) ---
has_unique_path(Grid) :-
    % require exactly two heads
    find_all_coords(Grid, 1, Heads),
    Heads = [Start, End],

    % collect all occupied coordinates (value > 0)
    findall((X,Y), (
        nth0(Y, Grid, Row), nth0(X, Row, V), V > 0
    ), Occupied),

    % reachable from Start over occupied cells
    reachable(Start, Occupied, [Start], Visited),

    % End must be reachable and all occupied cells visited
    member(End, Visited),
    sort(Visited, Vs), sort(Occupied, Os),
    Vs == Os.

% DFS over occupied coordinates
reachable(_, _, Vis, Vis) :- Vis == [] , !, fail.
reachable(Current, Occupied, VisIn, VisOut) :-
    findall(N, (
        adjacent(Current, N), member(N, Occupied), \+ member(N, VisIn)
    ), Nexts),
    reachable_list(Nexts, Occupied, VisIn, VisOut).

reachable_list([], _, Vis, Vis).
reachable_list([N|Ns], Occupied, VisIn, VisOut) :-
    ( member(N, VisIn)
    -> reachable_list(Ns, Occupied, VisIn, VisOut)
    ;  reachable(N, Occupied, [N|VisIn], VisMid),
       reachable_list(Ns, Occupied, VisMid, VisOut)
    ).

adjacent((X,Y),(NX,Y)) :- NX is X+1.
adjacent((X,Y),(NX,Y)) :- NX is X-1.
adjacent((X,Y),(X,NY)) :- NY is Y+1.
adjacent((X,Y),(X,NY)) :- NY is Y-1.

find_all_coords(Grid, Value, Coords) :-
    findall((X, Y), (
        nth0(Y, Grid, Row),
        nth0(X, Row, Value)
    ), Coords).
