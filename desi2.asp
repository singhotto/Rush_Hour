% neighborhood relation
car(0, 2, h, (3, 4)).
% car(1, 3, v, (1, 3)).
% car(2, 3, h, (4, 1)).
% car(3, 2, v, (4, 4)).
car(4, 3, v, (2, 6)).
% car(5, 2, h, (5, 5)).

exit(0, (3, 5)).

dim((1..6, 1..6)).

time(1..10).

% Allow horizontal movement across multiple cells
d(DR, 0) :- DR = -6..6.

% Allow vertical movement across multiple cells
d(0, DC) :- DC = -6..6.

% Define valid neighbors based on the updated d/2 relation
n((R, C), (R + DR, C + DC)) :- dim((R, C)), dim((R + DR, C + DC)), d(DR, DC).
% A car is described by its number (N), length (L), orientation (V), and anchor point (A).

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

% Occupied range for horizontal lines
occupied_range(0, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    dim((X1, Y)),
    dim((X2, Y)),
    not not_fully_occupied_range1(0, (X1, Y), (X2, Y)).

% Occupied range for vertical lines
occupied_range(0, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    dim((X, Y1)),
    dim((X, Y2)),
    not not_fully_occupied_range1(0, (X, Y1), (X, Y2)).

% Not Occupied range for horizontal lines
not_occupied_range(0, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    dim((X1, Y)),
    dim((X2, Y)),
    not not_fully_occupied_range2(0, (X1, Y), (X2, Y)).

% Not Occupied range for vertical lines
not_occupied_range(0, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    dim((X, Y1)),
    dim((X, Y2)),
    not not_fully_occupied_range2(0, (X, Y1), (X, Y2)).

% Define when a range is NOT fully occupied (horizontal)
not_fully_occupied_range1(0, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    dim((X1, Y)),
    dim((X2, Y)),
    X = X1..X2,
    not occupied(0, (X, Y)).

% Define when a range is NOT fully occupied (vertical)
not_fully_occupied_range1(0, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    dim((X, Y1)),
    dim((X, Y2)),
    Y = Y1..Y2,
    not occupied(0, (X, Y)).


% Define when a range is NOT fully occupied (horizontal)
not_fully_occupied_range2(0, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    dim((X1, Y)),
    dim((X2, Y)),
    X = X1..X2,
    not not_occupied(0, (X, Y)).

% Define when a range is NOT fully occupied (vertical)
not_fully_occupied_range2(0, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    dim((X, Y1)),
    dim((X, Y2)),
    Y = Y1..Y2,
    not not_occupied(0, (X, Y)).

% Vertical
get_r((R1, C), (R2, C), (R2, C), (R4, C), L) :-
    dim((R1, C)),
    dim((R2, C)),
    dim((R4, C)),
    R1+L <= 6, R2+L-1 <= 6,
    car(_, L, _, _),
    R1 > R2+L-1,
    R4 = R1- 1.

get_r((R1, C), (R2, C), (R3, C), (R4, C), L) :-
    dim((R1, C)),
    dim((R2, C)),
    dim((R3, C)),
    dim((R4, C)),
    R1+L <= 6, R2+L-1 <= 6,
    car(_, L, _, _),
    R2 > R1,
    R2 <= R1+L-1,
    R3 = R1 + L,
    R4 = R2 + L - 1.

get_r((R1, C), (R2, C), (R3, C), (R4, C), L) :-
    dim((R1, C)),
    dim((R2, C)),
    dim((R3, C)),
    dim((R4, C)),
    R1+L <= 6, R2+L-1 <= 6,
    car(_, L, _, _),
    R2 < R1,
    R1 <= R2+L-1,
    R3 = R2,
    R4 = R1 - 1.

get_r((R1, C), (R2, C), (R3, C), (R4, C), L) :-
    dim((R1, C)),
    dim((R2, C)),
    dim((R3, C)),
    dim((R4, C)),
    R1+L <= 6, R2+L-1 <= 6,
    car(_, L, _, _),
    R2 > R1+L-1,
    R3 = R1 + L,
    R4 = R2 + L - 1.


% Horizontal
get_r((R, C1), (R, C2), (R, C2), (R, C4), L) :-
    dim((R, C1)),
    dim((R, C2)),
    dim((R, C4)),
    C1+L <= 6, C2+L-1 <= 6,
    car(_, L, _, _),
    C1 > C2+L-1,
    C4 = C1 - 1.

get_r((R, C1), (R, C2), (R, C3), (R, C4), L) :-
    dim((R, C1)),
    dim((R, C2)),
    dim((R, C3)),
    dim((R, C4)),
    C1+L <= 6, C2+L-1 <= 6,
    car(_, L, _, _),
    C2 > C1,
    C2 <= C1+L-1,
    C3 = C1 + L,
    C4 = C2 + L - 1.

get_r((R, C1), (R, C2), (R, C3), (R, C4), L) :-
    dim((R, C1)),
    dim((R, C2)),
    dim((R, C3)),
    dim((R, C4)),
    C1+L <= 6, C2+L-1 <= 6,
    car(_, L, _, _),
    C2 < C1,
    C1 <= C2+L-1,
    C3 = C2,
    C4 = C1 - 1.

get_r((R, C1), (R, C2), (R, C3), (R, C4), L) :-
    dim((R, C1)),
    dim((R, C2)),
    dim((R, C3)),
    dim((R, C4)),
    C1+L <= 6, C2+L-1 <= 6,
    car(_, L, _, _),
    C2 > C1+L-1,
    C3 = C1+L,
    C4 = C2 + L - 1.

% Allow valid moves for cars based on their orientation and position
1 { move(T + 1, (R1, C), (R2, C), N) : n((R1, C), (R2, C)) } 1 :-
    not_occupied_range(T, (R3, C), (R4, C)),
    at(T, L, v, (R1, C), N),
    time(T + 1),
    get_r((R1, C), (R2, C), (R3, C), (R4, C), L).

1 { move(T + 1, (R, C1), (R, C2), N) : n((R, C1), (R, C2)) } 1 :-
    not_occupied_range(T, (R, C3), (R, C4)),
    at(T, L, h, (R, C1), N),
    time(T + 1),
    get_r((R, C1), (R, C2), (R, C3), (R, C4), L).

% Ensure moves respect the grid dimensions
:- 2 { move(T + 1, A, B, N) : dim(B) }, dim(A), time(T), car(N, _, _, _).
:- move(T, A, B, N), dim(A), time(T), car(N, _, _, _), not dim(B).
:- 2 { move(T,A,B, _) }, dim(A), time(T), dim(B).

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

% Occupied range for horizontal lines
occupied_range(T + 1, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    time(T + 1),
    dim((X1, Y)),
    dim((X2, Y)),
    not not_fully_occupied_range1(T + 1, (X1, Y), (X2, Y)).

% Occupied range for vertical lines
occupied_range(T + 1, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    time(T + 1),
    dim((X, Y1)),
    dim((X, Y2)),
    not not_fully_occupied_range1(T + 1, (X, Y1), (X, Y2)).

% Not Occupied range for horizontal lines
not_occupied_range(T + 1, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    time(T + 1),
    dim((X1, Y)),
    dim((X2, Y)),
    not not_fully_occupied_range2(T + 1, (X1, Y), (X2, Y)).

% Not Occupied range for vertical lines
not_occupied_range(T + 1, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    time(T + 1),
    dim((X, Y1)),
    dim((X, Y2)),
    not not_fully_occupied_range2(T + 1, (X, Y1), (X, Y2)).

% Define when a range is NOT fully occupied (horizontal)
not_fully_occupied_range1(T + 1, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    time(T + 1),
    dim((X1, Y)),
    dim((X2, Y)),
    X = X1..X2,
    not occupied(T + 1, (X, Y)).

% Define when a range is NOT fully occupied (vertical)
not_fully_occupied_range1(T + 1, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    time(T + 1),
    dim((X, Y1)),
    dim((X, Y2)),
    Y = Y1..Y2,
    not occupied(T + 1, (X, Y)).


% Define when a range is NOT fully occupied (horizontal)
not_fully_occupied_range2(T + 1, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    time(T + 1),
    dim((X1, Y)),
    dim((X2, Y)),
    X = X1..X2,
    not not_occupied(T + 1, (X, Y)).

% Define when a range is NOT fully occupied (vertical)
not_fully_occupied_range2(T + 1, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    time(T + 1),
    dim((X, Y1)),
    dim((X, Y2)),
    Y = Y1..Y2,
    not not_occupied(T + 1, (X, Y)).


% goal(T):- at(T, _, _, Exit, 0), exit(0, Exit), time(T), T=70.
% reachable(Exit, T) :- goal(T), exit(0, Exit).
% reachable((X1, Y1), T) :- move(T, (X1, Y1), (X2, Y2), _), reachable((X2, Y2), T + 1).

% valid_move((X1, Y1), (X2, Y2), T) :- move(T, (X1, Y1), (X2, Y2), _), reachable((X2, Y2), T + 1).


% #program check(t).

% % check goal
% :- exit(0, (3, 5)), not at(T, _, _, (3,5), 0), time(T), T = 70.

#show at/5.
% #show n/2.
% #show get_r/5.
#show occupied/2.
% #show occupied_range/3.
% #show not_occupied_range/3.
% #show not_fully_occupied_range1/3.
% #show not_fully_occupied_range2/3.
#show move/4.
% #show valid_move/3.