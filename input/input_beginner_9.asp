% (id, lunghezza, orientamento,  (riga, colonna))

car(0, 2, h, (3, 1)).
car(1, 3, h, (4, 3)).
car(2, 2, h, (1, 2)).
car(3, 2, v, (1, 1)).
car(4, 2, v, (2, 3)).
car(5, 2, h, (4, 1)).
car(6, 2, v, (2, 6)).
car(7, 2, v, (4, 6)).
car(8, 2, v, (1, 4)).
car(9, 2, v, (5, 3)).


dim((1..6, 1..6)).

%Goal 
exit(0, (3, 5)).