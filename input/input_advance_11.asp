% (id, lunghezza, orientamento,  (riga, colonna))

car(0, 2, h, (3, 3)).

car(1, 2, h, (1, 1)).
car(2, 2, v, (1, 3)).
car(3, 2, h, (1, 5)).

car(4, 2, v, (2, 1)).
car(5, 3, h, (2, 4)).

car(6, 3, v, (3, 2)).
car(7, 2, v, (3, 5)).
car(8, 2, v, (3, 6)).

car(9, 3, v, (4, 1)).
car(10, 2, h, (4, 3)).

car(11, 3, h, (5, 3)).
car(12, 2, v, (5, 6)).

car(13, 2, h, (6, 2)).
car(14, 2, h, (6, 4)).

dim((1..6, 1..6)).

%Goal 
exit(0, (3, 5)).