b_s((1..s), (1..s)).
% 0 red, 1 yellow, 2 blue, 3 green, 4 purple, 5 orange
car(0, 2, h, (3, 4)).
car(1, 3, v, (1, 3)).
car(2, 3, h, (4, 1)).
car(3, 2, v, (4, 4)).
car(4, 3, v, (2, 6)).
car(5, 2, h, (5, 5)).

% pos(0, 3, 4).
% pos(1, 1, 3).
% pos(2, 4, 1).
% pos(3, 4, 4).
% pos(4, 2, 6).
% pos(5, 5, 5).

%Goal 
exit(0, (3, 6)).