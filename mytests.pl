%% Custom tests, each case has either one or zero solutions.

% Ensure our program does not allow diagonals, should fail.
puzzle(no_diagonals, [1, 1, 1], [1, 1, 1],
    [[ 1, -1, -1],
     [-1,  2, -1],
     [-1, -1,  1]]).

% Solve puzzles with pre-filled obstacles
puzzle(obstacles, [-1, -1, -1, -1], [-1, -1, -1, -1],
    [[ 1, -1,  0,  1],
     [-1,  0,  0, -1],
     [-1, -1,  0, -1],
     [ 0, -1, -1, -1]]).

% Testing with certain target points the snake must go through
puzzle(prefilled, [-1, -1, -1, -1, -1], [-1, -1, -1, -1, -1],
    [[ 1, -1, -1, -1,  1],
     [-1,  2, -1,  2,  2],
     [-1, -1, -1, -1, -1],
     [-1, -1, -1, -1, -1],
     [ 2, -1,  2, -1, -1]]).

% Testing the 'no squares' rule. Should fail
puzzle(no_squares, [2, 2], [2, 2],
    [[-1,  1],
     [ 1, -1]]).

% Disconnected endpoints, should fail
puzzle(disconnected_endpoints, [-1, -1, -1], [-1, 0, -1],
    [[ 1,  0, -1],
     [-1,  0, -1],
     [-1,  0,  1]]).

% Challenging test case. 7x7 grid
puzzle(challenge, [3, 4, -1, -1, -1, -1, 5], [-1, -1, -1, -1, 5, 4, -1],
    [[-1,  0, -1, -1, -1, -1, -1],
     [ 1, -1, -1,  0, -1, -1, -1],
     [ 2, -1, -1, -1,  0, -1, -1],
     [-1, -1, -1, -1,  2, -1, -1],
     [-1, -1, -1, -1, -1, -1, -1],
     [-1, -1, -1, -1,  0, -1, -1],
     [-1, -1, -1, -1, -1, -1,  1]]).



%% Shows all solutions for a single puzzle (REMEMBER TO TAKE THIS OUT BEFORE SUBMITTING)
showAllSols(P) :-
    format("~n=== ~w ===~n", [P]),
    puzzle(P, RowClues, ColClues, Grid),
    time(findall(Sol, snake(RowClues, ColClues, Grid, Sol), Solutions)),
    ( Solutions = []
    -> format(">>> ~w: NO solution found~n", [P])
    ;  length(Solutions, N),
       format(">>> ~w: ~w solution(s) found~n", [P, N]),
       forall(member(Sol, Solutions),
              print_puzzle(RowClues, ColClues, Sol))
    ).

:- [tests].
