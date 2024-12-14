#include <incmode>.

% Enable consecutive moves in one timestep for faster solution discovery (non-optimal).

#program base.

% Vehicle definition: vehicle(ID, length, direction).
% direction: 0 for horizontal, 1 for vertical.

car(0, 2, h, (3, 4)).
car(1, 3, v, (1, 3)).
car(2, 3, h, (4, 1)).
car(3, 2, v, (4, 4)).
car(4, 3, v, (2, 6)).
car(5, 2, h, (5, 5)).

% Grid dimensions.
dim((X,Y)) :- X = 1..6, Y = 1..6. % Example: 6x6 grid.

% Neighborhood relation for moves.
d(1,0; -1,0). % Horizontal moves.
d(0,1; 0,-1). % Vertical moves.

n((X,Y),(X+DX,Y+DY)) :- dim((X,Y)), dim((X+DX,Y+DY)), d(DX,DY).

% Initial positions of vehicles (vehicle(ID, X, Y) at time step 0).
at(0,(X,Y),ID) :- car(ID, _, _, (X,Y)).

#program step(t).

% Guess moves for each vehicle. A vehicle can move forward or backward within its direction.
1 { move(t,ID,(X1,Y1),(X2,Y2)) :
    car(ID, L, D, _),
    valid_move(ID,(X1,Y1),(X2,Y2),D,L) } 1 :- car(ID, _, _, _), dim((X1,Y1)).

% Valid move definition for vehicles.
valid_move(ID, (X1,Y1), (X2,Y2), h, L) :- % Horizontal vehicle.
    X2 = X1, Y2 = Y1 + 1; Y2 = Y1 - 1,
    fits(ID,(X2,Y2),h,L).
valid_move(ID, (X1,Y1), (X2,Y2), v, L) :- % Vertical vehicle.
    Y2 = Y1, X2 = X1 + 1; X2 = X1 - 1,
    fits(ID,(X2,Y2),v,L).

% Ensure the vehicle fits in the new position after a move.
fits(ID, (X,Y), h, L) :- L-1 { dim((X,Y+Offset)) : Offset = 0..L-1, at(t-1,(X,Y+Offset),ID) }, car(ID, L, h, (X, Y)).
fits(ID, (X,Y), v, L) :- L-1 { dim((X+Offset,Y)) : Offset = 0..L-1, at(t-1,(X+Offset,Y),ID) }, car(ID, L, v, (X, Y)).

% Check for collisions: only one vehicle can occupy a cell.
:- 2 { at(t,(X,Y),_) }, dim((X,Y)).

% State transition for vehicle positions.
at(t,(X,Y),ID) :- at(t-1,(X,Y),ID), not moved(t,ID).
at(t,(X,Y),ID) :- at(t-1,(X1,Y1),ID), move(t,ID,(X1,Y1),(X,Y)).

% A vehicle is moved if any of its cells change position.
moved(t,ID) :- move(t,ID,_,_).

% Redundant constraints to enforce movement consistency.
:- move(t,ID,(X1,Y1),(X2,Y2)), not at(t-1,(X1,Y1),ID).
:- move(t,ID,(X1,Y1),(X2,Y2)), at(t-1,(X2,Y2),Other), Other != ID.
% :- move(t,ID,(X1,Y1),(X2,Y2)), not fits(ID,(X2,Y2),_,_).

#program check(t).

% Ensure all vehicles remain within the grid.
:- at(t,(X,Y),ID), not dim((X,Y)).

% Ensure the goal state is reached for the target vehicle.
% Example: Vehicle 1 must reach position (6,6).
:- car(0,_,_, _), not at(t,(3,5),0), query(t).

#show move/4.
#show at/3.
