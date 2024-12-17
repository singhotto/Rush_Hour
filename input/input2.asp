% 0 red, 1 yellow, 2 blue, 3 purple light, 4 orange, 5 green light
% (id, lunghezza, orientamento,  riga, colonna)

car(0, 2, h, 3, 4).
car(1, 3, v, 3, 3).
car(2, 3, h, 1, 4).
car(3, 3, v, 6, 2).
car(4, 2, h, 5, 5).
car(5, 2, v, 4, 4).

dim((1..6, 1..6)).

%Goal 
exit(0, (3, 5)).
