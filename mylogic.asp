#include <incmode>.

#program base.
% neighborhood relation
car(0, 2, h, (3, 4)).
% car(1, 3, v, (1, 3)).
% car(2, 3, h, (4, 1)).
% car(3, 2, v, (4, 4)).
% car(4, 3, v, (2, 6)).
% car(5, 2, h, (5, 5)).

exit(0, (3, 5)).

dim((1..6, 1..6)).

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

% Allow horizontal movement across multiple cells
d(DX, 0) :- DX = -6..6.

% Allow vertical movement across multiple cells
d(0, DY) :- DY = -6..6.

% Define valid neighbors based on the updated d/2 relation
n((X, Y), (X + DX, Y + DY)) :- dim((X, Y)), dim((X + DX, Y + DY)), d(DX, DY).

occupied((X, Y), 0) :- dim((X, Y)),  car(_, L, v, (X1, Y)), X >= X1, X < X1 + L.
occupied((X, Y), 0) :- dim((X, Y)),  car(_, L, h, (X, Y1)), Y >= Y1, Y < Y1 + L.

#program step(t).

free_range((X1, Y), (X2, Y), t) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 <= X2, 
    not occupied((X3, Y), t) : X3 = X1..X2.

free_range((X, Y1), (X, Y2), t) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 <= Y2, 
    not occupied((X, Y3), t) : Y3 = Y1..Y2.

% Verticle
can_move((X1, Y), (X2, Y), t) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, 
    car(_, L, v, (X1, Y)), 
    P = X1 + L,
    A = X2 + L - 1,
    free_range((P, Y), (A, Y), t-1).

can_move((X1, Y), (X2, Y), t) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, 
    car(_, L, v, (X1, Y)), 
    P = X2,
    A = X1 - 1,
    free_range((P, Y), (A, Y), t).

% Horizontal
can_move((X, Y1), (X, Y2), t) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, 
    car(_, L, h, (X, Y1)), 
    P = Y1 + L,
    A = Y2 + L - 1,
    free_range((X, P), (X, A), t).

can_move((X, Y1), (X, Y2), t) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, 
    car(_, L, h, (X, Y1)), 
    P = Y2,
    A = Y1 - 1,
    free_range((X, P), (X, A), t).

% guess moves
1{ move(t, A, B) : n(A, B)} 1 :- dim(A), dim(B), can_move(A, B, t-1).

% check moves
:- 2 { move(t,A,B) }, dim(A), dim(B).

occupied((X, Y), t) :- 
    dim((X, Y)),  
    car(N, L, v, (X1, Y)), 
    X >= X1, X < X1 + L,
    move(t-1,_,(X1, Y)).


occupied((X, Y), t) :- 
    dim((X, Y)),  
    car(N, L, h, (X, Y1)), 
    Y >= Y1, Y < Y1 + L,
    move(t-1, _, (X, Y1)).

% % % some redundant constraints
:- move(t,A,_), not can_move(A,_,t-1).
:- move(t,A,B), move(t-1,B,A).

% #program check(t).

% check domain knowledge
% :- not 1 { not at(T,A,_) : dim(A) } 1, time(T).
% :- 2 { at(T,A,N) }, dim(A), time(T).

% % check goal
% goal :- exit(N, (X,Y)), not at(T,(X,Y),N), car(N, _, _, (X, Y)), time(T).
% :- not goal.
   
% #show at/3.
% #show move/3.
#show occupied/2.
#show free_range/3.
% #show can_move/3.
% #show goal.
