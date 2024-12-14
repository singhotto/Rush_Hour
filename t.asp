#include <incmode>.

% if set to one, permits consecutive moves in one time step
% this will not provide optimal plans but usually finds solutions much faster


car(0, 2, h, (3, 4)).
car(1, 3, v, (1, 3)).
car(2, 3, h, (4, 1)).
car(3, 2, v, (4, 4)).
car(4, 3, v, (2, 6)).
car(5, 2, h, (5, 5)).

exit(0, (3, 5)).

dim((1..6, 1..6)).

#program base.

% neighborhood relation
d(1,0;0,1;-1,0;0,-1).
n((X,Y),(X+DX,Y+DY)) :- dim((X,Y)), dim((X+DX,Y+DY)), d(DX,DY).

% positions at time step zero
at(0,A,N) :- car(N, _, _, A).

% same_cell((X, Y), (X, Y)):- dim((X, Y)).

% overlap(N1, N2) :- 
%     N1 != N2,
%     car(N1, L1, v, (X1, Y)), 
%     car(N2, L2, v, (X2, Y)), 
%     X3 = X1..X1+L1-1, X4 = X2..X2+L2-1, 
%     same_cell((X3, Y), (X4, Y)).

% overlap(N1, N2) :- 
%     N1 != N2,
%     car(N1, L1, v, (X1, Y1)), 
%     car(N2, L2, h, (X2, Y2)), 
%     X3 = X1..X1+L1-1, Y4 = Y2..Y2+L2-1, 
%     same_cell((X3, Y1), (X2, Y4)).

% overlap(N1, N2) :- 
%     N1 != N2,
%     car(N1, L1, h, (X1, Y1)), 
%     car(N2, L2, v, (X2, Y2)), 
%     Y3 = Y1..Y1+L1-1, X4 = X2..X2+L2-1, 
%     same_cell((X1, Y3), (X4, Y2)).

% overlap(N1, N2) :- 
%     N1 != N2,
%     car(N1, L1, h, (X, Y1)), 
%     car(N2, L2, h, (X, Y2)), 
%     Y3 = Y1..Y1+L1-1, Y4 = Y2..Y2+L2-1, 
%     same_cell((X, Y3), (X, Y4)).

% :- overlap(N1, N2), car(N1, _, _, _), car(N2, _, _, _). 

#program step(t).

% guess moves
1 { move(t,A,B) : n(A,B) } 1 :- dim(B), not at(t-1,B,_).

% check moves
:- 2 { move(t,A,B) }, dim(A).

% % state transition
at(t,A,N) :- at(t-1,A,N), not move(t,A,_).
at(t,B,N) :- at(t-1,A,N),     move(t,A,B).

% % some redundant constraints
:- move(t,A,_), not at(t-1,A,_).
:- move(t,A,B), move(t-1,B,A).

#program check(t).

% % check domain knowledge
:- at(t,(X,Y),ID), not dim((X,Y)).
% :- not 1 { not at(t,A,_) : dim(A) } 1.
% :- 2 { at(t,A,N) }, dim(A).

% % check goal
:- exit(0, (X, Y)), not at(t,(X,Y),0), query(t).

#show move/3.
% #show at/3.
% #show equal/2.