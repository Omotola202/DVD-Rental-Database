--actors with same full name
SELECT DISTINCT a1.first_name, a1.last_name
FROM actor a1
JOIN actor a2
ON a1.actor_id != a2.actor_id AND a1.first_name = a2.first_name AND a1.last_name = a2.last_name

-- customers wt same address
SELECT c1.first_name, c1.last_name, c2.first_name, c2.last_name
FROM customer c1
JOIN customer c2
ON c1.customer_id != c2.customer_id AND c1.address_id = c2.address_id

--amt paid by each customer
SELECT concat(first_name,  ' ', last_name) 
full_name, SUM(amount) amt_paid
FROM customer 
JOIN payment 
USING (customer_id)
GROUP BY  1
ORDER BY 2 DESC

--movie rented the most
SELECT  f.title, COUNT(i.film_id)
FROM film f
JOIN inventory i
USING (film_id)
JOIN rental r
USING (inventory_id)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

--movie rented so far
SELECT COUNT(*)
FROM (
SELECT i.film_id, f.title 
FROM film f
JOIN inventory i
USING (film_id)
JOIN rental r
USING (inventory_id)
WHERE f.film_id = i.film_id
GROUP BY 1,2
ORDER BY 2 DESC)


--which movie have not been rented so far
SELECT COUNT(*)
FROM (SELECT f.film_id, f.title
FROM film f
WHERE f.film_id NOT IN 
(SELECT DISTINCT film_id
FROM inventory i
JOIN rental r
USING (inventory_id)))

--which customer have not rented movie so far
SELECT customer_id
FROM customer 
WHERE customer_id NOT IN 
(SELECT DISTINCT customer_id
FROM rental)

--num of movies each actor acted

SELECT CONCAT(first_name, ' ', last_name) full_name, COUNT(film_id)
FROM actor 
JOIN film_actor
USING (actor_id)
GROUP BY 1
ORDER BY 2 DESC

--actors that acted in more than 20 movies
SELECT CONCAT(first_name, ' ', last_name) full_name, COUNT(film_id)
FROM actor 
JOIN film_actor
USING (actor_id)
GROUP BY 1
HAVING COUNT(film_id) >=20
ORDER BY 2 DESC

--- count actors wt 8letters in first name
SELECT COUNT(*)
FROM (SELECT (first_name)
FROM actor  
WHERE LENGTH(first_name) = 8
)

--how many times PG was rented
SELECT f.title, i.film_id, COUNT(i.film_id) 
FROM film f
JOIN inventory i
USING (film_id)
JOIN rental r
USING (inventory_id)
GROUP BY 1, 2, f.rating
HAVING rating = 'PG'
ORDER BY 3 DESC
---or--
SELECT  i.film_id, COUNT(i.film_id) 
FROM film f
JOIN inventory i
USING (film_id)
JOIN rental r
USING (inventory_id)
WHERE rating = 'PG'
GROUP BY 1
ORDER BY 2 DESC

--movie rented in store 1 & not 2
SELECT film_id
FROM inventory 
WHERE store_id =1 AND film_id NOT IN (SELECT film_id
FROM inventory
WHERE store_id = 2)

--movie rented in any of the 2 store
SELECT film_id
FROM inventory 
WHERE store_id =1 
  UNION 
  (SELECT film_id
   FROM inventory
   WHERE store_id = 2)

--display title movie rented in both store at same time
SELECT title
FROM film
WHERE film_id IN
      (SELECT film_id
       FROM inventory 
       WHERE store_id =1 
INTERSECT 
     (SELECT film_id
      FROM inventory
      WHERE store_id = 2))

--or--
SELECT title
FROM film
WHERE film_id IN
    (SELECT film_id
     FROM inventory 
    WHERE store_id =1 AND film_id IN 
   (SELECT film_id
    FROM inventory
    WHERE store_id = 2))

--num of customer for each store--
SELECT COUNT(customer_id) customers, store_id
FROM customer
GROUP BY 2
ORDER BY 1 DESC

--movie title for the most rented movie in store 1--
SELECT film_id, title
FROM film
WHERE film_id IN (SELECT film_id
FROM inventory
JOIN rental r
USING (inventory_id)
WHERE store_id = 1  
GROUP BY film_id
HAVING COUNT(film_id) =
 (SELECT COUNT(film_id) times_rented
FROM inventory
JOIN rental r
USING (inventory_id)
WHERE store_id = 1 
GROUP BY film_id
ORDER BY 1 DESC
LIMIT 1))

--num of movies not offered for rent in the 2 stores--
SELECT COUNT(*)
FROM (SELECT *
FROM film
WHERE film_id NOT IN 
(SELECT DISTINCT film_id
FROM inventory
JOIN rental
USING(inventory_id)
WHERE store_id = 1
UNION
SELECT DISTINCT film_id
FROM inventory
JOIN rental
USING(inventory_id)
WHERE store_id = 2))

--customer_id that rented a movie more than once
WITH Temp AS 
(SELECT customer_id, film_id, rental_id, rental_date
FROM inventory
JOIN rental
USING (inventory_id))

SELECT t1.customer_id, COUNT(t1.film_id) film_count
FROM Temp t1 JOIN TEMP t2
ON t1.customer_id = t2.customer_id AND t2.film_id = t2.film_id AND t1.rental_id != t2.rental_id
GROUP BY T1.customer_id
HAVING COUNT(t1.film_id) > 1

--num of rented movie under each rating--
SELECT rating, COUNT(i.film_id)
FROM film f
JOIN inventory i
USING (film_id)
JOIN rental r
USING (inventory_id)
GROUP BY 1
ORDER BY 2 DESC

--revenue per store
SELECT store_id, SUM(amount) revenue
FROM inventory
JOIN rental
USING(inventory_id)
JOIN payment
USING(rental_id)
GROUP BY 1
ORDER BY 2 DESC

--show sum of revenue from both store--
SELECT store_id, SUM(amount) revenue
FROM inventory
JOIN rental
USING(inventory_id)
JOIN payment
USING(rental_id)
GROUP BY ROLLUP (store_id)
ORDER BY 2 DESC

--count of actors whose firstname don't start with "a"
SELECT COUNT(*)
FROM actor
WHERE first_name NOT LIKE ('A%')

-- actor with firstname that start with 'p' followed by 'e' or 'a' then any other letter
SELECT  first_name
FROM actor
WHERE first_name LIKE ('Pe%') OR first_name LIKE ('Pa%')

--or--
SELECT  first_name
FROM actor
WHERE first_name SIMILAR TO 'P(e|a)%' 

-- actor with firstname that start with 'p' followed by 5 other letter
SELECT  first_name
FROM actor
WHERE first_name LIKE ('P_____') 
--or--
SELECT  first_name
FROM actor
WHERE first_name SIMILAR TO ('P_____') 

--actor with first_name PaRkEr ignore the letter case. Then select actor with first_name PaRkEr match the letter case
-- To ignore
SELECT  *
FROM actor
WHERE first_name ~* 'PaRkEr' 


SELECT  *
FROM actor
WHERE first_name ILIKE 'PaRkEr' 

--To match

SELECT  *
FROM actor
WHERE first_name ~ 'PaRkEr' 


SELECT  *
FROM actor
WHERE first_name LIKE 'PaRkEr' 


--find actor first_name A followed by any letter from b to w then other letter 
SELECT  *
FROM actor
WHERE first_name SIMILAR TO 'A[b-w]%' 

/*create a table that provides the following details: 
actor's first and last name combined as full_name, film title, film description and length of the movie.
How many rows are there in the table? (ans : 5462 rows)
*/

SELECT CONCAT(last_name, ', ', first_name) full_name, title film_title, description, length
FROM actor a
JOIN film_actor fa
USING (actor_id)
JOIN film f
USING (film_id)

/*
Write a query that creates a list of actors and movies where the movie length was more than 60 minutes. 
How many rows are there in this query result? 
ans : 4900
*/
SELECT CONCAT(last_name, ', ', first_name) full_name, title film_title, description, length movie_lenght
FROM actor a
JOIN film_actor fa
USING (actor_id)
JOIN film f
USING (film_id)
WHERE length > 60

/*Write a query that captures the actor id, full name of the actor, and counts the number of movies each actor has made. 
(HINT: Think about whether you should group by actor id or the full name of the actor.) 
Identify the actor who has made the maximum number movies.
Gina Degeneres
*/
SELECT actor_id, CONCAT(last_name, ', ', first_name) full_name, COUNT(film_id) num_of_movie
FROM actor a
JOIN film_actor fa
USING (actor_id)
GROUP BY 1,2
ORDER BY 3 DESC

/* Write a query that displays a table with 4 columns: actor's full name, film title,
length of movie, and a column name "filmlen_groups" that classifies movies based on their length.
Filmlen_groups should include 4 categories: 1 hour or less, Between 1-2 hours, Between 2-3 hours, More than 3 hours.
*/

SELECT CONCAT(last_name, ', ', first_name) full_name, title film_title, length movie_lenght, 
CASE
	WHEN length < '60' THEN '1_hour_less'
	WHEN length >= '60' AND length < '120' THEN '1hours+'
	WHEN length >= '120' AND length <= '180' THEN '2hours+'
	ELSE '3hours+' END AS Filmlen_groups
FROM actor a
JOIN film_actor fa
USING (actor_id)
JOIN film f
USING (film_id)

/* Question 2: Write a query you to create a count of movies in each of the 4 filmlen_groups: 1 hour or less,
Between 1-2 hours, Between 2-3 hours, More than 3 hours.

filmlen_groups		filmcount_bylencat
1 hour or less			104
Between 1-2 hours		439
Between 2-3 hours		418
More than 3 hours		39
*/
SELECT DISTINCT(filmlen_groups),
      COUNT(title) OVER (PARTITION BY filmlen_groups) AS filmcount_bylencat
FROM 
	(SELECT title, length movie_lenght, 
	CASE
	WHEN length < '60' THEN '1_hour_less'
	WHEN length >= '60' AND length < '120' THEN '1hours+'
	WHEN length >= '120' AND length <= '180' THEN '2hours+'
	ELSE '3hours+' END AS Filmlen_groups
FROM film) t1
ORDER BY  filmlen_groups





