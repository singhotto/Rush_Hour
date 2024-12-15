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

len(1..6).

% Allow horizontal movement across multiple cells
d(DR, 0) :- DR = -6..6.

% Allow vertical movement across multiple cells
d(0, DC) :- DC = -6..6.

% Define valid neighbors based on the updated d/2 relation
n((R, C), (R + DR, C + DC)) :- dim((R, C)), dim((R + DR, C + DC)), d(DR, DC).



at(0, L, V, A, N) :- car(N, L, V, A).

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

#program step(t).

% Allow valid moves for cars based on their orientation and position
1 { move(t, (R1, C), (R2, C), N) : n((R1, C), (R2, C)) } 1 :-
    not_occupied_range(t-1, (R3, C), (R4, C)),
    at(t-1, L, v, (R1, C), N),
    get_r((R1, C), (R2, C), (R3, C), (R4, C), L).

1 { move(t, (R, C1), (R, C2), N) : n((R, C1), (R, C2)) } 1 :-
    not_occupied_range(t-1, (R, C3), (R, C4)),
    at(t-1, L, h, (R, C1), N),
    get_r((R, C1), (R, C2), (R, C3), (R, C4), L).

% Ensure moves respect the grid dimensions
:- 2 { move(t, A, B, N) : dim(B) }, dim(A), car(N, _, _, _).
:- move(t, A, B, N), dim(A), car(N, _, _, _), not dim(B).

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

% Occupied range for horizontal lines
occupied_range(t, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    dim((X1, Y)),
    dim((X2, Y)),
    not not_fully_occupied_range1(t, (X1, Y), (X2, Y)).

% Occupied range for vertical lines
occupied_range(t, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    dim((X, Y1)),
    dim((X, Y2)),
    not not_fully_occupied_range1(t, (X, Y1), (X, Y2)).

% Not Occupied range for horizontal lines
not_occupied_range(t, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    dim((X1, Y)),
    dim((X2, Y)),
    not not_fully_occupied_range2(t, (X1, Y), (X2, Y)).

% Not Occupied range for vertical lines
not_occupied_range(t, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    dim((X, Y1)),
    dim((X, Y2)),
    not not_fully_occupied_range2(t, (X, Y1), (X, Y2)).

% Define when a range is NOT fully occupied (horizontal)
not_fully_occupied_range1(t, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    dim((X1, Y)),
    dim((X2, Y)),
    X = X1..X2,
    not occupied(t, (X, Y)).

% Define when a range is NOT fully occupied (vertical)
not_fully_occupied_range1(t, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    dim((X, Y1)),
    dim((X, Y2)),
    Y = Y1..Y2,
    not occupied(t, (X, Y)).


% Define when a range is NOT fully occupied (horizontal)
not_fully_occupied_range2(t, (X1, Y), (X2, Y)) :-
    X1 <= X2,
    dim((X1, Y)),
    dim((X2, Y)),
    X = X1..X2,
    not not_occupied(t, (X, Y)).

% Define when a range is NOT fully occupied (vertical)
not_fully_occupied_range2(t, (X, Y1), (X, Y2)) :-
    Y1 <= Y2,
    dim((X, Y1)),
    dim((X, Y2)),
    Y = Y1..Y2,
    not not_occupied(t, (X, Y)).


% #program check(t).

% % check goal
% :- exit(N, A), not at(t, _, _, A,N), query(t).

% #show at/5.
% #show n/2.
% #show occupied/2.
% #show occupied_range/3.
% #show get_r/5.
% #show not_occupied_range/3.
#show move/4.