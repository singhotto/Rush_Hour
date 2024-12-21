% (id, lunghezza, orientamento,  (riga, colonna))

car(0, 2, h, (3, 4)).
car(1, 3, v, (1, 2)).
car(2, 2, h, (1, 3)).
car(3, 2, h, (1, 5)).
car(4, 2, v, (2, 6)).
car(5, 2, v, (4, 2)).
car(6, 2, v, (4, 4)).
car(7, 2, h, (4, 5)).
car(8, 2, v, (5, 5)).
car(9, 2, v, (5, 6)).
car(10, 3, h, (6,2)).


dim((1..6, 1..6)).

%Goal 
exit(0, (3, 5)).