% Input: Define grid size and vehicles
grid_size(6). % A 6x6 grid

car(0, 2, h, (3, 4)).
car(1, 3, v, (1, 3)).
car(2, 3, h, (4, 1)).
car(3, 2, v, (4, 4)).
car(4, 3, v, (2, 6)).
car(5, 2, h, (5, 5)).

dim((1..6, 1..6)).

exit(0, (3, 5)).

% Time domain
time(0..20). % Limit the planning horizon to 10 steps

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
can_move((X1, Y), (X2, Y), 0) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, time(0),
    at(0, L, v, (X1, Y), _), 
    P = X1 + L,
    A = X2 + L - 1,
    free_range(0, (P, Y), (A, Y)).

can_move((X1, Y), (X2, Y), 0) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, time(0),
    at(0, L, v, (X1, Y), _), 
    P = X2,
    A = X1 - 1,
    free_range(0, (P, Y), (A, Y)).

% Horizontal
can_move((X, Y1), (X, Y2), 0) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, time(0),
    at(0, L, h, (X, Y1), _), 
    P = Y1 + L,
    A = Y2 + L - 1,
    free_range(0, (X, P), (X, A)).

can_move((X, Y1), (X, Y2), 0) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, time(0),
    at(0, L, h, (X, Y1), _), 
    P = Y2,
    A = Y1 - 1,
    free_range(0, (X, P), (X, A)).

% move((X1, Y1), (X2, Y2), T + 1) :- at(T, (X1, Y1), _), can_move((X1, Y1), (X2, Y2), T), time(T).

% 1 { move(1, A, B) : can_move(A, B, 0) } 1 :- time(1).
% 1 { move(2, A, B) : can_move(A, B, 1) } 1 :- time(2).

1 { move(T + 1, A, B) : can_move(A, B, T) } 1 :- time(T).
:- 2 { move(T + 1, A,B) }, dim(A), dim(B).

% some redundant constraints
% :- move(T + 1,A,_), not at(T,_,_,A,_), time(T).
:- move(T + 1, A, B), move(T, B, A), time(T).
% :- move(T + 1, A, B), goal(T), time(T + 1).


at(T + 1, L, D, A, N) :-
    at(T, L, D, A, N),
    time(T + 1),
    not move(T + 1, A, _).

at(T + 1, L, D, B, N) :-
    at(T, L, D, A, N),
    time(T + 1),
    move(T + 1, A, B).


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
can_move((X1, Y), (X2, Y), T + 1) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, time(T + 1),
    at(T + 1, L, v, (X1, Y), _), 
    P = X1 + L,
    A = X2 + L - 1,
    free_range(T+1, (P, Y), (A, Y)).

can_move((X1, Y), (X2, Y), T + 1) :- 
    dim((X1, Y)), dim((X2, Y)), 
    X1 != X2, time(T + 1),
    at(T + 1, L, v, (X1, Y), _), 
    P = X2,
    A = X1 - 1,
    free_range(T+1, (P, Y), (A, Y)).

% Horizontal
can_move((X, Y1), (X, Y2), T + 1) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, time(T + 1),
    at(T + 1, L, h, (X, Y1), _), 
    P = Y1 + L,
    A = Y2 + L - 1,
    free_range(T+1, (X, P), (X, A)).

can_move((X, Y1), (X, Y2), T + 1) :- 
    dim((X, Y1)), dim((X, Y2)), 
    Y1 != Y2, time(T + 1),
    at(T+1, L, h, (X, Y1), _), 
    P = Y2,
    A = Y1 - 1,
    free_range(T+1, (X, P), (X, A)).


% reachable(Exit, T) :- goal(T), exit(0, Exit).
% reachable((X1, Y1), T) :- move((X1, Y1), (X2, Y2), T), reachable((X2, Y2), T + 1).

% valid_move((X1, Y1), (X2, Y2), T) :- move((X1, Y1), (X2, Y2), T), reachable((X2, Y2), T + 1).

% goal(T):- at(T, _, _, Exit, N), exit(N, Exit), time(T).
% :- not goal(T), time(T).
% #minimize { T : goal(T) }.
% :- not goal(T), time(T).


% Constraint to ensure that the goal is achieved at some time T
:- not at(_, _, _, Exit, N), exit(N, Exit).

% Minimize the time T at which the goal is achieved
#minimize { T : move(T, _, _) }.




#show at/5.
% #show occupied/2.
% #show not_occupied/2.
% #show free_range/3.
% #show move/3.
% #show valid_move/3.
% #show can_move/3.