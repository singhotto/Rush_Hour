% (id, lunghezza, orientamento,  (riga, colonna))

car(0, 2, h, (3, 3)).
car(1, 3, v, (3, 2)).
car(2, 3, h, (5, 4)).
car(3, 2, v, (1, 3)).
car(4, 2, h, (1, 1)).
car(5, 2, h, (1, 5)).
car(6, 2, v, (2, 5)).
car(7, 2, h, (2, 1)).
car(8, 2, v, (2, 6)).
car(9, 2, v, (1, 4)).

dim((1..6, 1..6)).

%Goal 
exit(0, (3, 5)).