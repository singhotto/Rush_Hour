% (id, lunghezza, orientamento,  (riga, colonna))

car(0, 2, h, (3, 1)).
car(1, 3, v, (2, 3)).
car(2, 3, v, (4, 6)).
car(3, 2, v, (4, 1)).
car(4, 2, v, (2, 6)).
car(5, 2, h, (5, 2)).
car(6, 2, v, (5, 5)).
car(7, 2, v, (5, 4)).
car(8, 2, h, (4, 4)).
car(9, 3, h, (6, 1)).

dim((1..6, 1..6)).

%Goal 
exit(0, (3, 5)).