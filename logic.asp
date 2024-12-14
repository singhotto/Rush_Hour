time(0..20).

% Horizontal car moving right multiple cells
move(ID, T, Steps) :- 
    car(ID, Length, h, Row, Col),
    Steps > 0, 
    time(T), T > 0,
    Steps = 1..(6 - (Col + Length)),
    Col + Length + Steps - 1 < 6,
    not blocked_h(ID, Row, Col, Steps, Length, T).

% Horizontal car moving left multiple cells
move(ID, T, Steps) :- 
    car(ID, Length, h, Row, Col),
    Steps > 0,
    Steps = 1..(6 - (Col + Length)),
    time(T), T > 0,
    Col - Steps >= 0,
    not blocked_h(ID, Row, Col - Steps, Steps, Length, T).

% Vertical car moving down multiple cells
move(ID, T, Steps) :- 
    car(ID, Length, v, Row, Col),
    Steps > 0,
    Steps = 1..(6 - (Row + Length)),
    time(T), T > 0,
    Row + Length + Steps - 1 < 6,
    not blocked_v(ID, Row, Col, Steps, Length, T).

% Vertical car moving up multiple cells
move(ID, T, Steps) :- 
    car(ID, Length, v, Row, Col),
    Steps > 0,
    Steps = 1..(6 - (Row + Length)),
    time(T), T > 0,
    Row - Steps >= 0,
    not blocked_v(ID, Row - Steps, Col, Steps, Length, T).


% Check if horizontal move is blocked
blocked_h(ID, Row, StartCol, Steps, Length, T) :-
    car(ID, Length, h, Row, StartCol),
    Offset = 0..Steps-1,
    Steps = 1..6,
    time(T), T > 0,
    Col = StartCol + Length + Offset,
    occupied(_, T-1, Row, Col).

blocked_h(ID, Row, StartCol, Steps, Length, T) :-
    car(ID, Length, h, Row, StartCol),
    Offset = 0..Steps-1,
    time(T), T > 0,
    Steps = 1..6,
    Col = StartCol - Offset,
    occupied(_, T-1, Row, Col).

% Check if vertical move is blocked
blocked_v(ID, StartRow, Col, Steps, Length, T) :-
    car(ID, Length, h, StartRow, Col),
    Offset = 0..Steps-1,
    time(T), T > 0,
    Steps = 1..6,
    Row = StartRow + Length + Offset,
    occupied(_, T-1, Row, Col).

blocked_v(ID, StartRow, Col, Steps, Length, T) :-
    car(ID, Length, h, StartRow, Col),
    Offset = 0..Steps-1,
    time(T), T > 0,
    Steps = 1..6,
    Row = StartRow - Offset,
    occupied(_, T-1, Row, Col).


% Update occupied cells after a horizontal move
occupied(ID, T, Row, Col) :- 
    car(ID, Length, h, Row, ColStartOld), % Use initial position from `car/5`
    move(ID, T, Steps),                   % Move by `Steps`
    time(T), T > 0,
    ColStart = ColStartOld + Steps,       % Compute new starting column
    Offset = 0..(Length - 1),             % Define range for `Offset`
    Col = ColStart + Offset.              % Compute occupied columns

% Update occupied cells after a vertical move
occupied(ID, T, Row, Col) :- 
    car(ID, Length, v, RowStartOld, Col),
    move(ID, T, Steps),
    time(T), T > 0,
    RowStart = RowStartOld + Steps,
    Offset = 0..(Length - 1),
    Row = RowStart + Offset.

% The red car (ID=0) reaches the exit
goal(T) :- exit(Row, Col), occupied(0, T, Row, Col).

#minimize { T : goal(T) }.

#show goal/1.


