% Time domain
time(0..100). % Limit the planning horizon to 10 steps

at(0, L, D, A, N) :- car(N, L, D, A).

occupied(0, (R, C)) :- 
    dim((R, C)),
    dim((R, C1)),
    at(0, L, h, (R, C1), _),
    C1 <= C,                        
    C < C1 + L.                     

occupied(0, (R, C)) :- 
    dim((R, C)),
    dim((R1, C)),
    at(0, L, v, (R1, C), _),
    R1 <= R,                        
    R < R1 + L.                    

not_occupied(0, A) :-
    dim(A),
    not occupied(0, A).



free_range(0, (X1, Y), (X2, Y)) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 <= X2, time(0),
    not_occupied(0, (X3, Y)) : X3 = X1..X2.

free_range(0, (X, Y1), (X, Y2)) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 <= Y2, time(0),
    not_occupied(0, (X, Y3)) : Y3 = Y1..Y2.

% Verticle
can_move(N, (X1, Y), (X2, Y), 0) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, time(0),
    at(0, L, v, (X1, Y), N), 
    P = X1 + L,
    A = X2 + L - 1,
    free_range(0, (P, Y), (A, Y)).

can_move(N, (X1, Y), (X2, Y), 0) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, time(0),
    at(0, L, v, (X1, Y), N), 
    P = X2,
    A = X1 - 1,
    free_range(0, (P, Y), (A, Y)).

% Horizontal
can_move(N, (X, Y1), (X, Y2), 0) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, time(0),
    at(0, L, h, (X, Y1), N), 
    P = Y1 + L,
    A = Y2 + L - 1,
    free_range(0, (X, P), (X, A)).

can_move(N, (X, Y1), (X, Y2), 0) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, time(0),
    at(0, L, h, (X, Y1), N), 
    P = Y2,
    A = Y1 - 1,
    free_range(0, (X, P), (X, A)).

% 1 { move(1, A, B, N) : can_move(N, A, B, 0) } 1 :- time(1).
% 1 { move(2, A, B, N) : can_move(N, A, B, 1) } 1 :- time(2).

1 { move(T + 1, A, B, N) : can_move(N, A, B, T) } 1 :- time(T).
:- 2 { move(T + 1, A,B, _) }, dim(A), dim(B).

:- move(T + 1, A, B, N), move(T, B, A, N), time(T).


at(T + 1, L, D, A, N) :-
    at(T, L, D, A, N),
    time(T + 1),
    not move(T + 1, A, _, N).

at(T + 1, L, D, B, N) :-
    at(T, L, D, A, N),
    time(T + 1),
    move(T + 1, A, B, N).


occupied(T + 1, (R, C)) :- 
    dim((R, C)),
    dim((R, C1)),
    at(T + 1, L, h, (R, C1), _),
    C1 <= C,                        
    C < C1 + L.                     

occupied(T + 1, (R, C)) :- 
    dim((R, C)),
    dim((R1, C)),
    at(T + 1, L, v, (R1, C), _),
    R1 <= R,                        
    R < R1 + L.           

not_occupied(T + 1, A) :-
    dim(A),
    time(T),
    not occupied(T + 1, A).

free_range(T+1, (X1, Y), (X2, Y)) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 <= X2, time(T + 1),
    not_occupied(T + 1, (X3, Y)) : X3 = X1..X2.

free_range(T+1, (X, Y1), (X, Y2)) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 <= Y2, time(T + 1),
    not_occupied(T + 1, (X, Y3)) : Y3 = Y1..Y2.

% Verticle
can_move(N, (X1, Y), (X2, Y), T + 1) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, time(T + 1),
    at(T + 1, L, v, (X1, Y), N), 
    P = X1 + L,
    A = X2 + L - 1,
    free_range(T+1, (P, Y), (A, Y)).

can_move(N, (X1, Y), (X2, Y), T + 1) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, time(T + 1),
    at(T + 1, L, v, (X1, Y), N), 
    P = X2,
    A = X1 - 1,
    free_range(T+1, (P, Y), (A, Y)).

% Horizontal
can_move(N, (X, Y1), (X, Y2), T + 1) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, time(T + 1),
    at(T + 1, L, h, (X, Y1), N), 
    P = Y1 + L,
    A = Y2 + L - 1,
    free_range(T+1, (X, P), (X, A)).

can_move(N, (X, Y1), (X, Y2), T + 1) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, time(T + 1),
    at(T+1, L, h, (X, Y1), N), 
    P = Y2,
    A = Y1 - 1,
    free_range(T+1, (X, P), (X, A)).

:- not move(_, _, Exit, N), exit(N, Exit).

#minimize { T : move(T, _, _, _) }.


#show move/4.