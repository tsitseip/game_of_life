:- use_module(library(option)).
:- use_module(library(clpfd)).

% Entry point with options and defaults
main(Options) :-
    option(a(A), Options, 2),                    % Lower birth/survival threshold
    option(b(B), Options, 3),                    % Upper birth/survival threshold
    option(c(C), Options, 3),                    % Exact value for birth when currently dead
    option(alive(ALIVE), Options, '#'),          % Symbol for alive cell
    option(dead(DEAD), Options, ' '),            % Symbol for dead cell
    option(k(K), Options, -1),                   % Number of steps (-1 means infinite)
    ( option(frame(Frame), Options)              % Optional custom starting frame
    -> true
    ;  glider(Frame)                             % Default to glider pattern
    ),
    main(Frame, A, B, C, ALIVE, DEAD, K).        % Call main simulation loop


% Base case: stop if K = 0
main(_, _, _, _, _, _, 0) :- !.

% Main recursive simulation step
main(Frame, A, B, C, ALIVE, DEAD, K) :-
    K1 #= K - 1,
    K2 is max(K1, -1),                                 % Keep K = -1 if infinite
    writeln("\x1b[23A"),                               % Move cursor up (ANSI escape)
    output2(Frame),                                    % Print current frame
    new_frame(Frame, A, B, C, NewFrame, ALIVE, DEAD),  % Compute next frame
    sleep(0.1),                                        % Delay for animation
    main(NewFrame, A, B, C, ALIVE, DEAD, K2).          % Recurse

% Output helpers
output1([X | L]) :- write(X), output1(L).
output1([]).

output2([X | L]) :- output1(X), nl(), output2(L).
output2([]).


% Helper to ensure all rows have same length
len(X, L) :- length(L, X).

% Generate new frame based on rules
new_frame(Frame, A, B, C, New_Frame, ALIVE, DEAD) :- 
    length(Frame, N),
    length(New_Frame, N),
    Frame = [X | _],
    length(X, M),
    maplist(len(M), New_Frame),                                     % All rows have length M
    N1 #= N - 1,
    M1 #= M - 1,
    numlist(0, N1, AllN),
    numlist(0, M1, AllM),
    pair(AllN, AllM, All),                                          % All cell coordinates
    maplist(check(Frame, A, B, C, New_Frame, ALIVE, DEAD), All).    % Update each cell



% Get wrapped (toroidal) cell at (X, Y)
get_cell((X, Y), Grid, Value) :-
    length(Grid, H),
    Ymod is (Y + H) mod H,
    nth0(Ymod, Grid, Row),
    length(Row, W),
    Xmod is (X + W) mod W,
    nth0(Xmod, Row, Value).


% Increment count if neighbor is ALIVE, otherwise unchanged
add(X, ALIVE, X1, ALIVE, _DEAD) :- X1 #= X + 1.
add(X, DEAD, X1, _ALIVE, DEAD) :- X1 #= X.

% Apply Game of Life rules to a single cell
check(Frame, A, B, C, New_Frame, ALIVE, DEAD, (I, J)) :-
    X #= 0,
    I1 #= I - 1,
    I2 #= I + 1,
    J1 #= J - 1,
    J2 #= J + 1,

    % Collect values of 8 neighbors (toroidal)
    get_cell((I1, J1), Frame, V1),
    get_cell((I1,  J), Frame, V2),
    get_cell((I1, J2), Frame, V3),
    get_cell((I , J1), Frame, V4),
    get_cell((I , J2), Frame, V5),
    get_cell((I2, J1), Frame, V6),
    get_cell((I2,  J), Frame, V7),
    get_cell((I2, J2), Frame, V8),

    % Count alive neighbors
    add(X , V1, X1, ALIVE, DEAD),
    add(X1, V2, X2, ALIVE, DEAD),
    add(X2, V3, X3, ALIVE, DEAD),
    add(X3, V4, X4, ALIVE, DEAD),
    add(X4, V5, X5, ALIVE, DEAD),
    add(X5, V6, X6, ALIVE, DEAD),
    add(X6, V7, X7, ALIVE, DEAD),
    add(X7, V8, X8, ALIVE, DEAD),

    % Get current and next cell values
    get_cell((I, J), New_Frame, V),
    get_cell((I, J), Frame, U),

    % Apply rule
    check_cell(U, V, X8, A, B, C, ALIVE, DEAD).

% Rule implementation
check_cell(DEAD, ALIVE, X8, _A, _B, X8, ALIVE, DEAD).
check_cell(DEAD, DEAD, X8, _A, _B, C, _ALIVE, DEAD) :- dif(X8, C).
check_cell(ALIVE, ALIVE, X8, A, B, _, ALIVE, _DEAD) :- X8 >= A, X8 =< B.
check_cell(ALIVE, DEAD, X8, A, B, _, ALIVE, DEAD) :- X8 < A; X8 > B.

% Utility: zip two lists
zip(A, B, (A, B)).

% Generate all pairs (Cartesian product) of two lists
pair([X | L1], L2, L3) :- 
    maplist(zip(X), L2, LL1),
    pair(L1, L2, LL2),
    append(LL1, LL2, L3).
pair([], _, []).



% Glider preset: 7x7 grid with a glider
glider(
    [
        [' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', '#', '#', ' ', ' ', ' ', ' '],
        [' ', '#', ' ', '#', ' ', ' ', ' '],
        [' ', '#', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ']
    ]
).

big_test() :-
    L = 
    [   [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '#', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '#', '#', '#', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '#', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '#', '#', '#', '#', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '#', '#', '#', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '#', '#', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '#', '#', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', '#', '#', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', '#', '#', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
        [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    ],
    main([frame=L]).