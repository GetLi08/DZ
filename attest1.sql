DROP VIEW  IF EXISTS bookings.total;
CREATE OR REPLACE VIEW bookings.total
AS
	WITH 
	port AS
	(
	SELECT airport_code,
	airport_name ->> lang() AS airport_name,
	city ->> lang() AS city
	FROM airports_data ml
	),
	air_desc AS
	(
	SELECT aircraft_code,
	model ->> lang() AS model,
	range
	FROM aircrafts_data ml
	),
	res_coutns AS
	(
	SELECT
		tick.ticket_no
		,book.book_date
		,tick.passenger_id
		,tick_f.fare_conditions
		,fly.aircraft_code
		,air_d.model
		,air_d.range
		,fly.departure_airport
		,port.airport_name
		,port.city
		,fly.arrival_airport
		,tick_f.amount
		,CONCAT_WS('-', fly.departure_airport, fly.arrival_airport ) AS full_path
		FROM flights AS fly
			JOIN ticket_flights AS tick_f ON fly.flight_id = tick_f.flight_id
			JOIN port AS port ON fly.departure_airport = port.airport_code 
			JOIN air_desc AS air_d ON fly.aircraft_code = air_d.aircraft_code
			JOIN tickets AS tick ON tick_f.ticket_no = tick.ticket_no
			JOIN bookings AS book ON tick.book_ref = book.book_ref
		)
SELECT 
	passenger_id
	,city
	,full_path
	,fare_conditions
	,amount
	,CASE 
		WHEN SUM(amount)/COUNT(amount) > 25000 AND (fare_conditions = 'Business') THEN 'VIP'
		WHEN SUM(amount)/COUNT(amount) > 7000 AND (fare_conditions = 'Comfort') THEN 'Premium'
		ELSE 'Normal'
	 END status
FROM res_coutns
WHERE amount > 21000
GROUP BY passenger_id, city, full_path, fare_conditions, amount
;

SELECT * FROM total
