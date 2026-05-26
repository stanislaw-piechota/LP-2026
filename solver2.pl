:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- [tests].
:- [mytests].

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
    % Enforce per-cell neighbor-degree constraints to prune search early
    enforce_degrees(Solution),

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
% With FD degree constraints in place, we only need to verify that
% (a) there are exactly two heads, and (b) all occupied cells (heads
% and body pieces) form one connected component. This is a simple
% connectivity check performed after labeling.
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

% --- 6. Degree enforcement (FD constraints) ---
enforce_degrees(Grid) :-
    length(Grid, Rows),
    Rows > 0,
    nth0(0, Grid, FirstRow), length(FirstRow, Cols),
    MaxY is Rows - 1,
    MaxX is Cols - 1,
    forall(between(0, MaxY, Y), (
        nth0(Y, Grid, Row),
        forall(between(0, MaxX, X), (
            nth0(X, Row, Var),
            Var #>= 0,
            Var #> 0 #<==> _Occ,        % occupancy boolean (unused directly)
            neighbor_coords(X, Y, MaxX, MaxY, Neis),
            collect_ne_occ(Neis, Grid, NeOccs),
            sum(NeOccs, #=, S),
            (Var #= 1) #==> (S #= 1),
            (Var #= 2) #==> (S #= 2)
        ))
    )).

neighbor_coords(X, Y, MaxX, MaxY, Neis) :-
    UpY is Y - 1, DownY is Y + 1, LeftX is X - 1, RightX is X + 1,
    findall((NX,NY), (
        member((NX,NY), [(X,UpY),(X,DownY),(LeftX,Y),(RightX,Y)]),
        NX >= 0, NY >= 0, NX =< MaxX, NY =< MaxY
    ), Neis).

collect_ne_occ([], _, []).
collect_ne_occ([(NX,NY)|T], Grid, [Occ|OccT]) :-
    nth0(NY, Grid, RowN),
    nth0(NX, RowN, NVar),
    NVar #> 0 #<==> Occ,
    collect_ne_occ(T, Grid, OccT).

