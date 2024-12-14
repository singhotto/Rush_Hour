% Input: Define grid size and vehicles
grid_size(6). % A 6x6 grid

car(0, 2, h, (3, 4)).
% car(1, 3, v, (1, 3)).
% car(2, 3, h, (4, 1)).
% car(3, 2, v, (4, 4)).
car(4, 3, v, (2, 6)).
% car(5, 2, h, (5, 5)).

dim((1..6, 1..6)).

exit(0, (3, 5)).

% Time domain
time(0..200). % Limit the planning horizon to 10 steps

% Define occupied cells by vehicles at time t
occupied((X, Y), T) :- dim((X, Y)), time(T), car(_, L, v, (X1, Y)), X >= X1, X < X1 + L.
occupied((X, Y), T) :- dim((X, Y)), time(T), car(_, L, h, (X, Y1)), Y >= Y1, Y < Y1 + L.

not_occupied(A, T) :- dim(A), not occupied(A, T), time(T).

free_range((X1, Y), (X2, Y), T) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 <= X2, time(T),
    not occupied((X3, Y), T) : X3 = X1..X2.

free_range((X, Y1), (X, Y2), T) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 <= Y2, time(T),
    not occupied((X, Y3), T) : Y3 = Y1..Y2.

% Verticle
can_move((X1, Y), (X2, Y), T) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, time(T),
    car(_, L, v, (X1, Y)), 
    P = X1 + L,
    A = X2 + L - 1,
    free_range((P, Y), (A, Y), T).

can_move((X1, Y), (X2, Y), T) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, time(T),
    car(_, L, v, (X1, Y)), 
    P = X2,
    A = X1 - 1,
    free_range((P, Y), (A, Y), T).

% Horizontal
can_move((X, Y1), (X, Y2), T) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, time(T),
    car(_, L, h, (X, Y1)), 
    P = Y1 + L,
    A = Y2 + L - 1,
    free_range((X, P), (X, A), T).

can_move((X, Y1), (X, Y2), T) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, time(T),
    car(_, L, h, (X, Y1)), 
    P = Y2,
    A = Y1 - 1,
    free_range((X, P), (X, A), T).

same_cell((X, Y), (X, Y)):- dim((X, Y)).

overlap(N1, N2) :- 
    N1 != N2,
    car(N1, L1, v, (X1, Y)), 
    car(N2, L2, v, (X2, Y)), 
    X3 = X1..X1+L1-1, X4 = X2..X2+L2-1, 
    same_cell((X3, Y), (X4, Y)).

overlap(N1, N2) :- 
    N1 != N2,
    car(N1, L1, v, (X1, Y1)), 
    car(N2, L2, h, (X2, Y2)), 
    X3 = X1..X1+L1-1, Y4 = Y2..Y2+L2-1, 
    same_cell((X3, Y1), (X2, Y4)).

overlap(N1, N2) :- 
    N1 != N2,
    car(N1, L1, h, (X1, Y1)), 
    car(N2, L2, v, (X2, Y2)), 
    Y3 = Y1..Y1+L1-1, X4 = X2..X2+L2-1, 
    same_cell((X1, Y3), (X4, Y2)).

overlap(N1, N2) :- 
    N1 != N2,
    car(N1, L1, h, (X, Y1)), 
    car(N2, L2, h, (X, Y2)), 
    Y3 = Y1..Y1+L1-1, Y4 = Y2..Y2+L2-1, 
    same_cell((X, Y3), (X, Y4)).

:- overlap(N1, N2), car(N1, _, _, _), car(N2, _, _, _). 

at(0, (X, Y), N) :- car(N, _, _, (X, Y)).

occupied((X, Y), 0) :- dim((X, Y)),  car(_, L, v, (X1, Y)), X >= X1, X < X1 + L.
occupied((X, Y), 0) :- dim((X, Y)),  car(_, L, h, (X, Y1)), Y >= Y1, Y < Y1 + L.

% move((X1, Y1), (X2, Y2), T + 1) :- at(T, (X1, Y1), _), can_move((X1, Y1), (X2, Y2), T), time(T).

1 { move(A, B, T + 1) : can_move(A, B, T) } 1 :- dim(B), not at(T, B, _), time(T).
:- 2 { move(A,B, T + 1) }, dim(A).

at(T + 1,A,N) :- at(T,A,N), not move(A,_, T + 1), time(T).
at(T + 1,B,N) :- at(T,A,N),     move(A,B, T + 1), time(T).

% 1 { at(T, A, N) : dim(A) } 1 :- car(N, _, _, _), time(T).
% :- at(T, A, N1), at(T, A, N2), N1 != N2, time(T).

pred(T, T1) :- time(T), time(T1), T1 = T - 1.

:- move(T, A, _), pred(T, T1), not at(T1, A, _).
:- move(T, A, B), pred(T, T1), move(T1, B, A).



reachable(Exit, T) :- goal(T), exit(0, Exit).
reachable((X1, Y1), T) :- move((X1, Y1), (X2, Y2), T), reachable((X2, Y2), T + 1).

valid_move((X1, Y1), (X2, Y2), T) :- move((X1, Y1), (X2, Y2), T), reachable((X2, Y2), T + 1).

goal(T):- at(T, Exit, 0), exit(0, Exit), time(T).
:- not goal(T), time(T), T=20.
% #minimize { T : time(T) }.

% #show at/3.
#show move/3.
#show valid_move/3.