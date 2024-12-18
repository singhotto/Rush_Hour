#include <incmode>.

#program base.

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
    X1 <= X2,
    not_occupied(0, (X3, Y)) : X3 = X1..X2.

free_range(0, (X, Y1), (X, Y2)) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 <= Y2,
    not_occupied(0, (X, Y3)) : Y3 = Y1..Y2.

% Verticle
can_move(N, (X1, Y), (X2, Y), 0) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2,
    at(0, L, v, (X1, Y), N), 
    P = X1 + L,
    A = X2 + L - 1,
    free_range(0, (P, Y), (A, Y)).

can_move(N, (X1, Y), (X2, Y), 0) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2,
    at(0, L, v, (X1, Y), N), 
    P = X2,
    A = X1 - 1,
    free_range(0, (P, Y), (A, Y)).

% Horizontal
can_move(N, (X, Y1), (X, Y2), 0) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2,
    at(0, L, h, (X, Y1), N), 
    P = Y1 + L,
    A = Y2 + L - 1,
    free_range(0, (X, P), (X, A)).

can_move(N, (X, Y1), (X, Y2), 0) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2,
    at(0, L, h, (X, Y1), N), 
    P = Y2,
    A = Y1 - 1,
    free_range(0, (X, P), (X, A)).


#program step(t).

1 { move(t, A, B, N) : can_move(N, A, B, t-1) } 1.
:- 2 { move(t, A,B, _) }, dim(A), dim(B).

:- move(t, A, B, N), move(t-1, B, A, N).


at(t, L, D, A, N) :-
    at(t-1, L, D, A, N),
    not move(t, A, _, N).

at(t, L, D, B, N) :-
    at(t-1, L, D, A, N),
    move(t, A, B, N).


occupied(t, (R, C)) :- 
    dim((R, C)),
    dim((R, C1)),
    at(t, L, h, (R, C1), _),
    C1 <= C,                        
    C < C1 + L.                     

occupied(t, (R, C)) :- 
    dim((R, C)),
    dim((R1, C)),
    at(t, L, v, (R1, C), _),
    R1 <= R,                        
    R < R1 + L.           

not_occupied(t, A) :-
    dim(A),
    not occupied(t, A).

free_range(t, (X1, Y), (X2, Y)) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 <= X2,
    not_occupied(t, (X3, Y)) : X3 = X1..X2.

free_range(t, (X, Y1), (X, Y2)) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 <= Y2,
    not_occupied(t, (X, Y3)) : Y3 = Y1..Y2.

% Verticle
can_move(N, (X1, Y), (X2, Y), t) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2,
    at(t, L, v, (X1, Y), N), 
    P = X1 + L,
    A = X2 + L - 1,
    free_range(t, (P, Y), (A, Y)).

can_move(N, (X1, Y), (X2, Y), t) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2,
    at(t, L, v, (X1, Y), N), 
    P = X2,
    A = X1 - 1,
    free_range(t, (P, Y), (A, Y)).

% Horizontal
can_move(N, (X, Y1), (X, Y2), t) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2,
    at(t, L, h, (X, Y1), N), 
    P = Y1 + L,
    A = Y2 + L - 1,
    free_range(t, (X, P), (X, A)).

can_move(N, (X, Y1), (X, Y2), t) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2,
    at(t, L, h, (X, Y1), N), 
    P = Y2,
    A = Y1 - 1,
    free_range(t, (X, P), (X, A)).


#program check(t).

% Constraint to ensure that the goal is achieved at some time T
:- not move(_, _, Exit, N), exit(N, Exit), query(t).

#show move/4.
