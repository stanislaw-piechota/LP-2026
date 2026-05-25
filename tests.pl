%% =====================================================================
%% Snake puzzle: test file
%% =====================================================================
%%
%% Include this file in your solver as follows:
%%
%%     :- [tests].
%%
%% This file provides:
%%   - a set of test puzzles (of increasing size and difficulty),
%%   - a set of test solutions, including deliberately WRONG solutions,
%%   - test predicates to check your solver,
%%   - printing routines.
%%
%% You must define snake/4 yourself, in your own file.
%%
%% ---------------------------------------------------------------------
%% Looking at puzzles
%% ---------------------------------------------------------------------
%%
%%   showPuzzle(p2x2).      % show one puzzle
%%   showPuzzle(P).         % show all puzzles (press ; to step through)
%%   solvePuzzle(p2x2).     % run your solver on one puzzle and print it
%%
%% ---------------------------------------------------------------------
%% Checking your solver
%% ---------------------------------------------------------------------
%%
%% These tests are exactly the ones used for grading. Run each one at
%% the ?- prompt, one at a time.
%%
%%   testSanity.    % feeds your solver clearly-wrong solutions.
%%                  % Your solver must REJECT all of them.
%%                  % Expected result: false.
%%
%%   testSolved.    % feeds your solver known-correct solutions.
%%                  % Your solver must ACCEPT all of them.
%%                  % Expected result: false  (means: no correct
%%                  % solution was wrongly rejected).
%%                  % If this is slow, try testSolved2 instead.
%%
%%   testErrors.    % feeds your solver solutions with a single error.
%%                  % Your solver must REJECT all of them.
%%                  % Expected result: false.
%%
%%   testCycles.    % feeds your solver solutions that form a closed
%%                  % loop instead of a path.
%%                  % Your solver must REJECT all of them.
%%                  % Expected result: false.
%%
%%   testTricky.    % feeds your solver atypical wrong solutions
%%                  % (mismatched clue counts, touching heads, ...).
%%                  % Your solver must REJECT all of them.
%%                  % Expected result: false.
%%
%%   tinyPuzzle(P).         % solve and print the small puzzles.
%%   multipleSolutions(P).  % solve and print puzzles with two solutions
%%                          % (each should be printed exactly twice).
%%   testLargePuzzles(P).   % solve and print the larger puzzles.
%%
%% A quick way to run the lot:
%%
%%   test.
%%
%% ---------------------------------------------------------------------
%% Fast sanity checks while developing
%% ---------------------------------------------------------------------
%%
%%   checkCorrect(P).   % does your solver accept the known solution
%%                      % of puzzle P? (Should be instant, even if your
%%                      % solver is slow at *finding* solutions.)
%%
%%   checkSolver(P).    % does your solver FIND the correct solution of
%%                      % puzzle P? Prints the puzzle if it does not.
%%                      % (Only for puzzles with a single solution.)
%%
%% ---------------------------------------------------------------------
%% Notes
%% ---------------------------------------------------------------------
%%
%% - Most puzzles have exactly one solution. A few have two; these are
%%   marked. Make sure every distinct solution is given exactly once.
%% - The solver you hand in should not print anything itself.
%% =====================================================================


%% ---------------------------------------------------------------------
%% Helper predicates
%% ---------------------------------------------------------------------

solvePuzzle(P)
  :- puzzle(P,RowClues,ColClues,Grid)
   , snake(RowClues,ColClues,Grid,Solution)   %% you define snake/4 !
   , print_only_grid(Solution).

showPuzzle(P)
  :- puzzle(P,RowClues,ColClues,Grid)
   , print_puzzle(RowClues,ColClues,Grid).

showSolution(P)
  :- solution(P,RowClues,ColClues,Grid)
   , print_puzzle(RowClues,ColClues,Grid).

%% Does your solver accept the known-correct solution of P?
%% This should be instant, even if your solver is slow at searching.
checkCorrect(P)
  :- isCorrect(P)
   , solution(P,RowClues,ColClues,Grid)
   , snake(RowClues,ColClues,Grid,Solution)
   , Grid = Solution.

%% Does your solver FIND the correct solution of P?
%% Prints the puzzle and both solutions if it does not.
%% Only meaningful for puzzles with a single solution.
checkSolver(P)
  :- puzzle(P,RowClues,ColClues,Grid)
   , solution(P,RowClues,ColClues,CorrectSolution)
   , print(P), write(": "), flush_output
   , checkSolverSingle(RowClues,ColClues,Grid,CorrectSolution).
checkSolverSingle(RowClues,ColClues,Grid,CorrectSolution)
  :- snake(RowClues,ColClues,Grid,Solution), !
   , checkSolverResult(RowClues,ColClues,Grid,Solution,CorrectSolution).
checkSolverSingle(_,_,_,_)
  :- write("no solution (error)."), nl
   , false.
checkSolverResult(RowClues,ColClues,Grid,Solution,CorrectSolution)
  :- CorrectSolution \= Solution, !
   , write("incorrect."), nl
   , print_puzzle(RowClues,ColClues,Grid)
   , print_puzzle(RowClues,ColClues,Solution)
   , print_puzzle(RowClues,ColClues,CorrectSolution)
   , false.
checkSolverResult(_,_,_,_,_)
  :- write("correct."), nl
   , false.


%% ---------------------------------------------------------------------
%% Test predicates
%% ---------------------------------------------------------------------
%% Each test prints the name of the puzzle it is currently checking,
%% so if a test stops early you can see which puzzle caused it.

testSanity  :- unsolvableSanity(P),  writeln(P), solution(P,RowClues,ColClues,Grid), snake(RowClues,ColClues,Grid,_).
testErrors  :- unsolvableErrors(P),  writeln(P), solution(P,RowClues,ColClues,Grid), snake(RowClues,ColClues,Grid,_).
testTricky  :- unsolvableTricky(P),  writeln(P), solution(P,RowClues,ColClues,Grid), snake(RowClues,ColClues,Grid,_).
testCycles  :- unsolvableCycles(P),  writeln(P), solution(P,RowClues,ColClues,Grid), snake(RowClues,ColClues,Grid,_).

testSolved  :- isCorrect(P), writeln(P), solution(P,RowClues,ColClues,Grid), \+ solvedTest(RowClues,ColClues,Grid).
solvedTest(RowClues,ColClues,Grid)
  :- snake(RowClues,ColClues,Grid,Grid).

testSolved2 :- isCorrect(P), solution(P,RowClues,ColClues,Grid), \+ snake(RowClues,ColClues,Grid,Grid).

tinyPuzzle(P)        :- isTiny(P),  puzzle(P,RowClues,ColClues,Grid), snake(RowClues,ColClues,Grid,Sol), print_puzzle(RowClues,ColClues,Sol).
multipleSolutions(P) :- hasTwo(P),  puzzle(P,RowClues,ColClues,Grid), snake(RowClues,ColClues,Grid,Sol), print_puzzle(RowClues,ColClues,Sol).
testLargePuzzles(P)  :- isLarge(P), puzzle(P,RowClues,ColClues,Grid), snake(RowClues,ColClues,Grid,Sol), print_only_grid(Sol).

%% Run the whole suite in sequence, each test wrapped in time/1.
%%
%%   - Rejection tests (Sanity, Solved, Errors, Cycles, Tricky) are
%%     expected to FAIL: failing means no bad solution was accepted and
%%     no correct solution was rejected. A test that SUCCEEDS is a bug
%%     in your solver, and is flagged with a warning.
%%   - Solving tests print each puzzle by name, then the solution(s)
%%     your solver finds, and how many.
%%
%% Note: this includes the large puzzles, so a full run can take a few
%% minutes depending on how fast your solver is.
test :-
    timedTest(testSanity),
    timedTest(testSolved),
    timedTest(testErrors),
    timedTest(testCycles),
    timedTest(testTricky),
    forall(isTiny(P),  timedSolveAll(P)),
    forall(hasTwo(P),  timedSolveAll(P)),
    forall(isLarge(P), timedSolveAll(P)).

%% Run one rejection test, timed. Expected to fail.
timedTest(Test) :-
    format("~n=== ~w ===~n", [Test]),
    ( time(Test)
    -> format(">>> WARNING: ~w succeeded -- a wrong solution was accepted!~n", [Test])
    ;  format(">>> ~w failed, as it should~n", [Test]) ).

%% Solve one puzzle, print every solution found, report how many. Timed.
%% Used for small puzzles: enumerating all solutions is cheap, and a
%% duplicate solution is a bug worth seeing.
timedSolveAll(P) :-
    format("~n=== ~w ===~n", [P]),
    puzzle(P, RowClues, ColClues, Grid),
    time(findall(S, snake(RowClues, ColClues, Grid, S), Sols)),
    ( Sols == []
    -> format(">>> ~w: NO solution found~n", [P])
    ;  forall(member(S, Sols), print_puzzle(RowClues, ColClues, S)),
       length(Sols, N),
       format(">>> ~w: ~w solution(s) found~n", [P, N]) ).

%% Solve one puzzle, print only the first solution. Timed.
%% Used for large puzzles, where enumerating every solution may be slow.
timedSolveOne(P) :-
    format("~n=== ~w ===~n", [P]),
    puzzle(P, RowClues, ColClues, Grid),
    ( time(once(snake(RowClues, ColClues, Grid, Sol)))
    -> print_puzzle(RowClues, ColClues, Sol)
    ;  format(">>> ~w: NO solution found~n", [P]) ).


%% ---------------------------------------------------------------------
%% Puzzle categories
%% ---------------------------------------------------------------------

isTiny(p2x2).
isTiny(p2x2b).
isTiny(p3x3).
isTiny(p3x3b).
isTiny(p4x3).
isTiny(p4x4).
isTiny(p4x4b).

isLarge(pCycle).
isLarge(p5x5).
isLarge(p5x5s).
isLarge(p7x7).
isLarge(p7x7_b).
isLarge(p7x7_c).
isLarge(p10x10).
isLarge(p10x10_hard1).
isLarge(p10x10_hard2).
isLarge(p12x12).
isLarge(p12x12_hard1).
isLarge(p12x12_hard2).



hasTwo(p3x3b).
hasTwo(p5x5_two).


:- discontiguous unsolvableTricky/1.
:- discontiguous unsolvableErrors/1.
:- discontiguous unsolvableCycles/1.
:- discontiguous unsolvableSanity/1.
:- discontiguous isCorrect/1.
:- discontiguous solution/4.
:- discontiguous puzzle/4.


%% ---------------------------------------------------------------------
%% Puzzles (in roughly increasing order of difficulty)
%% ---------------------------------------------------------------------

puzzle(p2x2,[-1,-1],
 [ 2,-1],
[[-1, 1]
,[ 1,-1]]).

puzzle(p2x2b,[-1,-1],
 [ -1,-1],
[[ 1, 1]
,[-1,-1]]).

puzzle(p3x3,[ 1,-1,-1],
 [ 2,-1,-1],
[[-1,-1,1]
,[-1,-1,-1]
,[ 1,-1,-1]]).

% Two solutions.
puzzle(p3x3b,[-1,1,-1],
 [-1,1,-1],
[[-1,-1,1]
,[-1,-1,-1]
,[ 1,-1,-1]]).

puzzle(p4x3,[2,-1,-1,3],
 [-1,-1,-1],
[[ 1,-1, 1]
,[-1,-1,-1]
,[-1,-1,-1]
,[-1,-1,-1]]).

% Unique solution (two solutions if no cycle detection was built).
puzzle(pCycle,[-1,-1,-1,-1,3],
 [-1,-1,-1],
[[ 1,-1, 1]
,[-1,-1,-1]
,[-1,-1,-1]
,[-1,-1,-1]
,[-1,-1,-1]]).

puzzle(p4x4,[-1,-1,2,-1],
 [ -1,-1,-1,3],
[[-1, 1,-1,-1]
,[-1,-1,-1,-1]
,[ 1,-1,-1,-1]
,[-1,-1,-1,-1]]).

puzzle(p4x4b,[-1,-1,3,-1],
 [ -1,-1,-1,3],
[[-1, 1,-1,-1]
,[-1,-1,-1,-1]
,[ 1,-1,-1,-1]
,[-1,-1,-1,-1]]).

puzzle(p5x5,[-1,-1,-1,-1, 5],
 [-1, 2, 4,-1,-1],
[[-1, 1,-1,-1,-1]
,[-1,-1,-1,-1,-1]
,[ 1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1]]).

puzzle(p5x5_two,[3,1,5,1,3],
 [3,2,3,2,3],
[[-1,-1, 1,-1,-1]
,[-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1]
,[-1,-1, 1,-1,-1]]).

puzzle(p5x5s,[-1,-1, 3,-1,-1],
 [-1, 4,-1,-1, 3],
[[-1, 1,-1,-1,-1]
,[-1,-1,-1,-1,-1]
,[ 1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1]]).

puzzle(p7x7,[ 4, 5, 3,-1,-1,-1, 3],
 [ 3,-1,-1,-1, 3, 5, 4],
[[-1, 1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1, 1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]]).

puzzle(p10x10,[-1,3,-1,5,-1,7,-1,9,-1,-1],
 [-1,-1, 2,-1,-1,-1, 6,-1, 8,-1],
[[-1,-1,-1,-1,-1,-1,-1,-1,-1, 1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1, 1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]]
).

puzzle(p12x12,[-1, 3, 7,-1, -1, 8,  2, 2, -1,2,3,4],
  [ 8, 5, 2, 6, 4, 5, 6, 4, 5,-1, 7],
[ [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 1]
, [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
, [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
, [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
, [-1,-1,-1,-1,-1, 1,-1,-1,-1,-1,-1]
, [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
, [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
, [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
, [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
, [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
, [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
, [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]]
).

puzzle(p7x7_b,[5,-1,5,-1,3,-1,3],
 [-1,4,-1,1,4,-1,3],
[[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[ 1,-1,-1,-1, 1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]]
).

puzzle(p7x7_c,[-1,4,-1,2,5,-1,6],
 [6,-1,5,-1,6,-1,5],
[[-1,-1,-1,-1,-1, 1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1, 1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1]]
).

puzzle(p10x10_hard1,[-1,5,-1,8,-1,-1,4,-1,3,-1],
 [3,-1,-1,-1,-1,7,-1,5,-1,7],
[[-1,-1,-1,-1,-1,-1, 0,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1, 0,-1,-1,-1, 0,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1, 0,-1, 1,-1, 1,-1]]
).

puzzle(p10x10_hard2,[-1,-1,6,-1,-1,6,-1,7,-1,8],
 [-1,4,6,-1,6,-1,7, 6,-1,8],
[[-1,-1, 0,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1, 0,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[ 1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1, 1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]]
).

puzzle(p12x12_hard1,[-1,3,7,-1,4,8,-1,2,-1, 6,3,4],
 [8,-1,-1,6,-1,5,6,-1,5,8,7,-1],
[[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1, 1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1]]
).

puzzle(p12x12_hard2,[-1,-1,-1,6,-1,5,6,-1,5,8,7,-1],
 [4,3,2,-1,2,-1,8,-1,5,-1,3,-1],
[[-1,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1, 1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 1]
,[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]]
).


%% ---------------------------------------------------------------------
%% Known-correct solutions (your solver must ACCEPT these)
%% ---------------------------------------------------------------------

isCorrect(p3x3).
solution(p3x3, [1, -1, -1], [2, -1, -1],
 [[0, 0, 1], [2, 2, 2], [1, 0, 0]]).

isCorrect(p4x3).
solution(p4x3,[2, -1, -1, 3], [-1, -1, -1],
 [[1, 0, 1], [2, 0, 2], [2, 0, 2], [2, 2, 2]]).

isCorrect(pCycle).
solution(pCycle,[-1, -1, -1, -1, 3], [-1, -1, -1],
  [[1, 0, 1], [2, 0, 2], [2, 0, 2], [2, 0, 2], [2, 2, 2]]).

isCorrect(p4x4).
solution(p4x4,[-1,-1,2,-1],[ -1,-1,-1,3],
  [[0, 1, 2, 0], [0, 0, 2, 2], [1, 0, 0, 2], [2, 2, 2, 2]]).

isCorrect(p5x5s).
solution(p5x5s,[-1,-1,3,-1,-1],[-1, 4,-1,-1, 3],
 [ [0, 1, 2, 2, 0]
 , [0, 0, 0, 2, 2]
 , [1, 2, 0, 0, 2]
 , [0, 2, 0, 2, 2]
 , [0, 2, 2, 2, 0]]).

isCorrect(p7x7).
solution(p7x7,[4, 5, 3, -1, -1, -1, 3],[3, -1, -1, -1, 3, 5, 4],
[ [0, 1, 0, 0, 2, 2, 2]
, [2, 2, 0, 2, 2, 0, 2]
, [2, 0, 0, 2, 0, 0, 2]
, [2, 2, 2, 2, 0, 2, 2]
, [0, 0, 0, 0, 0, 2, 0]
, [0, 0, 0, 1, 0, 2, 0]
, [0, 0, 0, 2, 2, 2, 0]]
).

% Correct solutions for the larger puzzles. p10x10 and p12x12 are not
% marked isCorrect (testSolved would be slow); they are here so that
% checkSolver/1 can be used with them.
solution(p10x10,[-1, 3, -1, 5, -1, 7, -1, 9, -1, -1],
  [-1,-1, 2,-1,-1,-1, 6,-1, 8,-1],
[ [ 2, 2, 2, 2, 2, 2, 2, 0, 2, 1]
, [ 2, 0, 0, 0, 0, 0, 2, 0, 2, 0]
, [ 2, 0, 0, 2, 2, 2, 2, 0, 2, 0]
, [ 2, 2, 0, 2, 0, 0, 0, 0, 2, 2]
, [ 0, 2, 0, 2, 0, 1, 0, 0, 0, 2]
, [ 2, 2, 0, 2, 2, 2, 0, 0, 2, 2]
, [ 2, 0, 0, 0, 0, 0, 0, 0, 2, 0]
, [ 2, 2, 2, 2, 2, 2, 2, 0, 2, 2]
, [ 0, 0, 0, 0, 0, 0, 2, 0, 0, 2]
, [ 0, 0, 0, 0, 0, 0, 2, 2, 2, 2]]
).

solution(p12x12,[-1, 3, 7,-1, -1,-1, -1, -1, -1,2,3,4],
  [ 8, 5, 2, 6, 4, 5, 6, 4, 5,-1, 7],
[ [ 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 1]
, [ 2, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0]
, [ 2, 0, 0, 2, 2, 2, 2, 2, 0, 2, 0]
, [ 2, 2, 0, 2, 0, 0, 0, 0, 0, 2, 2]
, [ 0, 2, 0, 2, 0, 1, 0, 0, 0, 0, 2]
, [ 2, 2, 0, 2, 2, 2, 0, 0, 2, 2, 2]
, [ 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0]
, [ 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0]
, [ 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2]
, [ 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2]
, [ 0, 0, 0, 0, 0, 0, 2, 0, 0, 2, 2]
, [ 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 0]]
).


%% ---------------------------------------------------------------------
%% Wrong solutions: SANITY (two errors per case)
%% Your solver must reject all of these.
%% ---------------------------------------------------------------------

unsolvableSanity(pConnect5).
solution(pConnect5,[ 3,-1,-1],
 [-1,-1,-1],
[[ 1, 2, 1]
,[ 2, 2, 2]
,[ 2, 2, 2]]).

unsolvableSanity(pCluesSanity).
solution(pCluesSanity,[ 1, 4,-1],
 [-1,-1,-1,-1],
[[ 1, 0, 0, 1]
,[ 2, 0, 0, 2]
,[ 2, 2, 2, 2]]).

unsolvableSanity(pGridSanity1).
solution(pGridSanity1,[-1,-1, 3],
 [-1,-1,-1],
[[ 1, 0, 1]
,[ 3, 3, 3]
,[ 3, 3, 3]]).

unsolvableSanity(pGridSanity2).
solution(pGridSanity2,[-1,-1,-1],
 [ 3,-1, 3],
[[ 1, 0, 1]
,[ 2, 0, 2]
,[ 1, 0, 1]]).

unsolvableSanity(pTouchSanity).
solution(pTouchSanity,[-1,-1,-1,-1],
 [-1,-1,-1,-1],
[[ 1, 1, 0, 0]
,[ 2, 2, 0, 0]
,[ 0, 0, 2, 2]
,[ 0, 0, 2, 2]]).

unsolvableSanity(connectedSanity).
solution(connectedSanity,[-1,-1,-1],
 [ 2,-1, 2],
[[ 1, 0, 2]
,[ 0, 0, 0]
,[ 2, 0, 1]]).


%% ---------------------------------------------------------------------
%% Wrong solutions: ERRORS (one error per case)
%% Your solver must reject all of these.
%% ---------------------------------------------------------------------

unsolvableErrors(pNoTouch1).
solution(pNoTouch1,[-1,-1,-1],
 [ 3,-1,-1],
[[ 1, 0, 0]
,[ 2, 2, 1]
,[ 2, 2, 0]]).

unsolvableErrors(pNoTouch2).
solution(pNoTouch2,[-1,-1, 3,-1],
 [-1, 3,-1, 3],
[[ 0, 1, 0, 1]
,[ 2, 2, 0, 2]
,[ 2, 0, 2, 2]
,[ 2, 2, 2, 0]]).

unsolvableErrors(pNoTouch3).
solution(pNoTouch3,[-1,-1, 3,-1],
 [ 3,-1, 3,-1],
[[ 1, 0, 1, 0]
,[ 2, 0, 2, 2]
,[ 2, 2, 0, 2]
,[ 0, 2, 2, 2]]).

unsolvableErrors(pConnect1).
solution(pConnect1,[-1,-1,-1,-1,-1],
 [ 1,-1, 3,-1],
[[ 1, 2, 1, 0]
,[ 0, 2, 0, 0]
,[ 0, 2, 2, 2]
,[ 0, 2, 0, 2]
,[ 0, 2, 2, 2]]).

unsolvableErrors(pConnect2).
solution(pConnect2,[-1],
 [-1,-1,-1],
[[ 1, 0, 1]]).

unsolvableErrors(pConnect3).
solution(pConnect3,[ 2,-1],
 [-1,-1,-1],
[[ 1, 0, 1]
,[ 2, 0, 2]]).

unsolvableErrors(pConnect4).
solution(pConnect4,[ 3,-1,-1],
 [-1,-1,-1],
[[ 1, 2, 1]
,[ 2, 0, 2]
,[ 2, 2, 2]]).

unsolvableErrors(pClueErr1).
solution(pClueErr1,[ 3, 2,-1],
 [-1,-1,-1],
[[ 1, 0, 1]
,[ 2, 0, 2]
,[ 2, 2, 2]]).

unsolvableErrors(pClueErr2).
solution(pClueErr2,[ 1, 2,-1],
 [-1,-1,-1],
[[ 1, 0, 1]
,[ 2, 0, 2]
,[ 2, 2, 2]]).

unsolvableErrors(pClueErr3).
solution(pClueErr3,[ 1,-1,-1],
 [ 2,-1,-1],
[[ 1, 0, 1]
,[ 2, 0, 2]
,[ 2, 2, 2]]).

unsolvableErrors(pClueErr4).
solution(pClueErr4,[ 1,-1,-1],
 [ 4,-1,-1],
[[ 1, 0, 1]
,[ 2, 0, 2]
,[ 2, 2, 2]]).


%% ---------------------------------------------------------------------
%% Wrong solutions: TRICKY (atypical: clue counts, head touching, sizes)
%% Your solver must reject all of these.
%% ---------------------------------------------------------------------

unsolvableTricky(pHeadCorner).
solution(pHeadCorner,[-1,-1,-1,-1,-1, 6],
 [-1,-1, 3,-1, 2, 6],
[[ 2, 2, 2, 2, 2, 2]
,[ 1, 0, 0, 0, 0, 2]
,[ 0, 2, 2, 2, 0, 2]
,[ 2, 2, 0, 1, 0, 2]
,[ 2, 0, 0, 0, 0, 2]
,[ 2, 2, 2, 2, 2, 2]]).

unsolvableTricky(pHeadTouching).
solution(pHeadTouching,[-1,-1,-1],
 [ 2,-1,-1],
[[ 2, 2, 2]
,[ 1, 0, 2]
,[ 0, 1, 2]]).

unsolvableTricky(pNoHeads).
solution(pNoHeads,[ 0, 0, 0],
 [ 0, 0, 0],
[[ 0, 0, 0]
,[ 0, 0, 0]
,[ 0, 0, 0]]).

unsolvableTricky(pGridSize1).
solution(pGridSize1,[-1,-1,-1],
 [ 3,-1,-1,-1],
[[ 1, 0, 0, 0]
,[ 2, 0, 0, 0]
,[ 1, 0, 0]]).

unsolvableTricky(pGridSize2).
solution(pGridSize2,[-1,-1,-1],
 [ 3,-1,-1],
[[ 1, 0, 0]
,[ 2, 0, 0, 0]
,[ 1, 0, 0]]).

unsolvableTricky(pGridSize3).
solution(pGridSize3,[-1,-1,-1],
 [-1,-1,-1],
[[ 1, 0, 0]
,[ 2, 0, 0]
,[ 1, 0, 0]
,[ 0]]).

unsolvableTricky(pGridSize4).
solution(pGridSize4,[-1,-1,-1],
 [-1,-1,-1],
[[ 1, 0, 0]
,[ 2, 0, 0]
,[ 1, 0, 0]
,[ 0, 0, 0]]).

unsolvableTricky(pClueSize1).
solution(pClueSize1,[-1,-1,-1,-1],
 [-1,-1,-1],
[[ 1, 0, 0]
,[ 2, 0, 0]
,[ 2, 2, 1]]).

unsolvableTricky(pClueSize2).
solution(pClueSize2,[-1,-1,-1],
 [-1,-1,-1,-1],
[[ 1, 0, 0]
,[ 2, 0, 0]
,[ 2, 2, 1]]).

unsolvableTricky(pClueSize3).
solution(pClueSize3,[-1,-1],
 [-1,-1,-1],
[[ 1, 0, 0]
,[ 2, 0, 0]
,[ 2, 1, 0]]).


%% ---------------------------------------------------------------------
%% Wrong solutions: CYCLES (closed loops instead of a path)
%% Your solver must reject all of these.
%% ---------------------------------------------------------------------

unsolvableCycles(pCycleErr).
solution(pCycleErr,[-1,-1,-1,-1,3],
 [ -1,-1,-1],
[[ 1, 2, 1]
,[ 0, 0, 0]
,[ 2, 2, 2]
,[ 2, 0, 2]
,[ 2, 2, 2]]).

unsolvableCycles(pCycle2).
solution(pCycle2,[-1,-1,-1,-1,-1,-1],
 [ 5,-1,-1,-1,-1, 5],
[[ 1, 2, 2, 2, 2, 0]
,[ 0, 0, 0, 0, 2, 2]
,[ 2, 2, 2, 0, 0, 2]
,[ 2, 0, 2, 2, 0, 2]
,[ 2, 0, 0, 2, 0, 2]
,[ 2, 2, 2, 2, 0, 1]]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%  Printing  %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Only print the grid (without the clues)
print_only_grid([]) :- nl.
print_only_grid([GridH|GridT]) :- print_row(GridH), nl, print_only_grid(GridT).

% Printing function for the puzzle (starting with empty part in top-left corner)
print_puzzle(RowClues,ColClues,Grid) :- write('     '), print_colclues(RowClues,ColClues,ColClues,Grid).
% Print the column clues
print_colclues(RowClues,[], ColClues,Grid) :- nl, write('     '), print_colline(RowClues,ColClues,Grid).
print_colclues(RowClues,[ColH|ColT], ColClues,Grid) :- print_clue(ColH), print_colclues(RowClues,ColT,ColClues,Grid).
% Print a column line
print_colline(RowClues,[],Grid) :- nl, print_grid(RowClues,[],Grid).
print_colline(RowClues,[_|ColT],Grid) :- write('---'), print_colline(RowClues,ColT,Grid).
% Print the grid itself (with the row clues)
print_grid([],[],[]) :- nl.
print_grid([RowH|RowT],[],[GridH|GridT]) :- print_clue(RowH), write('| '), print_row(GridH), nl, print_grid(RowT,[],GridT).
% Print row
print_row([]).
print_row([H|T]) :- print_cell(H), print_row(T).
% Print cell
print_cell(-1) :- write(' ? ').
print_cell(0) :- write(' - ').
print_cell(2) :- write('[#]').
print_cell(1) :- write('[S]').
% Print clue (assuming one-digit clues)
print_clue(-1) :- write('   ').
print_clue(0) :- write(' 0 ').
print_clue(1) :- write(' 1 ').
print_clue(2) :- write(' 2 ').
print_clue(3) :- write(' 3 ').
print_clue(4) :- write(' 4 ').
print_clue(5) :- write(' 5 ').
print_clue(6) :- write(' 6 ').
print_clue(7) :- write(' 7 ').
print_clue(8) :- write(' 8 ').
print_clue(9) :- write(' 9 ').
