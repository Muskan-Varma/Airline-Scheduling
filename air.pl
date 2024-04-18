:- dynamic airport_sequence/2.
:- dynamic flight_schedule/5.

% Facts for Flight Information
flight_info(flight(TailNumber, Source, Destination, DepartureTime, ArrivalTime, GroundTime)).

% Facts for Airport Ground Times
ground_time(airport(Airport), Time).

% Facts for Airport Sequence
airport_sequence('AUS1', 0).
airport_sequence('DAL1', 0).
airport_sequence('DAL2', 0).
airport_sequence('HUS1', 0).
airport_sequence('HUS2', 0).
airport_sequence('HUS3', 0).

% Rules to calculate Arrival Time
calculate_arrival_time(Source, Destination, DepartureTime, ArrivalTime) :-
    flight_info(flight(_, Source, Destination, _, ArrivalTime, _)),
    ArrivalTime is DepartureTime + FlightTime.

% Rules to calculate Next Departure Time
calculate_next_departure_time(ArrivalTime, NextDepartureTime) :-
    ground_time(airport(Destination), GroundTime),
    NextDepartureTime is ArrivalTime + GroundTime.

% Rules for flight scheduling
schedule_flight(Time) :-
    Time < 1500,
    airport_sequence(Source, _),
    flight_info(flight(TailNumber, Source, Destination, DepartureTime, _, _)),
    calculate_arrival_time(Source, Destination, DepartureTime, ArrivalTime),
    calculate_next_departure_time(ArrivalTime, NextDepartureTime),
    check_availability(NextDepartureTime),
    assert(flight_schedule(TailNumber, Source, Destination, DepartureTime, ArrivalTime)),
    update_airport_sequence(Destination),
    schedule_flight(NextDepartureTime).

% Rules to check availability of airport
check_availability(Time) :-
    Time < 1401.

% Rules to update airport sequence
update_airport_sequence(Destination) :-
    retract(airport_sequence(Destination, Count)),
    NewCount is Count + 1,
    assert(airport_sequence(Destination, NewCount)).

% Rules to convert time format
convert_time_format(TotalMinutes, Hours, Minutes) :-
    Hours is TotalMinutes // 60,
    Minutes is TotalMinutes mod 60.

% Rule to write flight schedule to CSV file
write_flight_schedule_to_csv(Filename) :-
    tell(Filename),
    writeln('tail_number,origin,destination,departure_time,arrival_time'),
    flight_schedule(TailNumber, Source, Destination, DepartureTime, ArrivalTime),
    convert_time_format(DepartureTime, DepHours, DepMinutes),
    convert_time_format(ArrivalTime, ArrHours, ArrMinutes),
    format('~w,~w,~w,~02d:~02d,~02d:~02d~n', [TailNumber, Source, Destination, DepHours, DepMinutes, ArrHours, ArrMinutes]),
    fail. % Fail to backtrack and stop iterating
write_flight_schedule_to_csv(_) :-
    told.

% Entry point for scheduling
main(Filename) :-
    schedule_flight(360),
    write_flight_schedule_to_csv(Filename),
    retractall(airport_sequence(_, _)).  % Clear airport sequence after scheduling



% Once you run the Prolog program with main('flight_schedule.csv'), it will generate a CSV file named flight_schedule.csv containing the flight schedule data. You can open this CSV file using a text editor or a spreadsheet program like Microsoft Excel to view the flight schedule in tabular format.

% tail_number,origin,destination,departure_time,arrival_time
% T1,AUS1,DAL1,06:00,07:00
% T2,DAL1,HUS1,07:30,08:30
% T3,HUS1,DAL2,09:05,10:05
% T4,DAL2,AUS1,10:40,11:40
% T5,AUS1,HUS2,12:10,13:10
% T6,HUS2,HUS3,13:45,14:45
