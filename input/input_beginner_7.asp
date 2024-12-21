% (id, lunghezza, orientamento,  (riga, colonna))

car(0, 2, h, (3, 3)).
car(1, 3, v, (1, 5)).
car(2, 2, v, (4, 3)).
car(3, 3, h, (2, 2)).
car(4, 2, v, (2, 6)).
car(5, 2, h, (1, 3)).
car(6, 2, v, (5, 4)).
car(7, 2, h, (6, 5)).
car(8, 2, h, (5, 5)).
car(9, 3, h, (4, 4)).

dim((1..6, 1..6)).

%Goal 
exit(0, (3, 5)).