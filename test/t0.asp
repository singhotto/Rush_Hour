%*
initial:
04 13    02
09 01 06 07
05 12 03 11
14 08 10 15

goal:
   01 02 03
04 05 06 07
08 09 11 12
12 13 14 15
*%

% initial situation
in(1,1, 4; 1,2,13;         1,4, 2).
in(2,1, 9; 2,2, 1; 2,3, 6; 2,4, 7).
in(3,1, 5; 3,2,12; 3,3, 3; 3,4,11).
in(4,1,14; 4,2, 8; 4,3,10; 4,4,15).

% goal situation
go(        1,2, 1; 1,3, 2; 1,4, 3).
go(2,1, 4; 2,2, 5; 2,3, 6; 2,4, 7).
go(3,1, 8; 3,2, 9; 3,3,10; 3,4,11).
go(4,1,12; 4,2,13; 4,3,14; 4,4,15).


% % initial situation
% in(1,1, 4; 1,2,13;         1,4, 2).
% in(2,1, 9; 2,2, 1; 2,3, 6; 2,4, 7).
% in(3,1, 5; 3,2,12; 3,3, 3; 3,4,11).
% in(4,1,14; 4,2, 8; 4,3,10; 4,4,15).

% % goal situation
% go(        1,2, 1; 1,3, 2; 1,4, 3).
% go(2,1, 4; 2,2, 5; 2,3, 6; 2,4, 7).
% go(3,1, 8; 3,2, 9; 3,3,10; 3,4,11).
% go(4,1,12; 4,2,13; 4,3,14; 4,4,15).

% dimenaions
dim((1..4,1..4)).