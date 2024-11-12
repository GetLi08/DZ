--Задача - найти какие категории фильмов из видеопроката интересуют конкретного потребителя, 
--чтобы в дальнейшем выстроить систему рекомендаций
WITH cat_name AS
(
SELECT pay.customer_id,
			pay.rental_id, 
			pay.amount,
			rent.inventory_id,
			inv.film_id,
			filmcat.category_id,
			f.length,
			cat.category_id,
			cat.name,
			CASE
				WHEN f.length > 0 AND f.length <= 50 THEN 'Shorts'
				WHEN f.length > 50 then 'Long'
			END AS lg
	FROM payment AS pay
	INNER JOIN rental AS rent
	ON pay.rental_id=rent.rental_id
	INNER JOIN inventory AS inv
	on rent.inventory_id=inv.inventory_id
	INNER JOIN film_category AS filmcat
	ON inv.film_id=filmcat.category_id
	INNER JOIN category AS cat
	ON filmcat.category_id=cat.category_id
	INNER JOIN film AS f
	ON f.film_id=filmcat.film_id
)
SELECT customer_id,
	cat_name.name,
	lg,
	amount
FROM cat_name
GROUP BY customer_id, amount, name, lg
ORDER BY customer_id, amount DESC
