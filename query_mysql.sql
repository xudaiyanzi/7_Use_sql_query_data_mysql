-- 1a. Display the first and last names of all actors from the table `actor`.
-- -------determine the db to use:
USE sakila;

SELECT first_name, last_name
FROM actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT UPPER(CONCAT(first_name," ", last_name)) AS "Actor Name"
 FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";


-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT *
FROM actor
WHERE last_name LIKE "%GEN%";


-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name,first_name ASC;


-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS counts
FROM actor
GROUP BY last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS counts
FROM actor
GROUP BY last_name
HAVING counts >=2;


-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO" 
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";


-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = "GROUCHO" 
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";


-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
  -- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
-- ---show the table values
SHOW CREATE TABLE address;


-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, a.address
FROM staff s
INNER JOIN address a ON s.address_id = a.address_id;


-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT sp.staff_id, SUM(amount) AS total_amount
FROM 
 (
  SELECT p.staff_id, p.amount, p.payment_date
  FROM staff s
  RIGHT JOIN payment p ON s.staff_id = p.staff_id
  WHERE p.payment_date < "2005-08-01 00:00:00"
 ) AS sp
GROUP BY sp.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(actor_id) AS number_of_actors
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title;


-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(inventory_id) AS number_of_copies
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible";


-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

  -- ![Total amount paid](Images/total_payment.png)
SELECT c.last_name, c.first_name, SUM(amount) AS total_payment, c.customer_id
FROM customer c
INNER JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name ASC;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT fl.title
FROM 
(
   SELECT f.title
   FROM film f
   INNER JOIN language l ON f.language_id = l.language_id
   WHERE l.name = "English"
) AS fl
WHERE fl.title LIKE "K%" OR fl.title LIKE "Q%"
ORDER BY fl.title ASC;


-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT a.actor_id, a.first_name,a.last_name
FROM actor a
WHERE a.actor_id IN
  (
	SELECT fa.actor_id 
    FROM  film_actor fa 
	INNER JOIN film f ON fa.film_id = f.film_id
	WHERE f.title = "Alone Trip"
  )
ORDER BY a.actor_id ASC;


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.email, c.first_name, c.last_name
FROM customer c
INNER JOIN address a ON c.address_id = a.address_id
WHERE a.address_id IN
(  
   SELECT a.address_id
   FROM address a 
   INNER JOIN city ON city.city_id = a.city_id
   WHERE city.country_id IN
       (
		SELECT country_id
		FROM country
		WHERE country = "Canada"
		)
);


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT f.title, f.film_id
FROM film f
INNER JOIN film_category fc ON fc.film_id = f.film_id
WHERE fc.film_id IN
(  
   SELECT fc.film_id
   FROM film_category fc 
   WHERE fc.category_id IN
       (
		SELECT category_id
		FROM category
		WHERE name = "family"
		)
)
ORDER BY f.film_id;


-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, f.film_id, COUNT(r.rental_id) AS rent_times
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY rent_times DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT i.store_id, SUM(p.amount) AS total_business_in_dollars
FROM payment p
INNER JOIN rental r ON r.rental_id = p.rental_id
INNER JOIN inventory i ON i.inventory_id = r.inventory_id
GROUP BY i.store_id
ORDER BY i.store_id ASC;


-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, co.country
FROM store s
INNER JOIN address a ON s.address_id = a.address_id
INNER JOIN city c ON c.city_id = a.city_id
INNER JOIN country co ON c.country_id = co.country_id
ORDER BY s.store_id ASC;


-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS total_revenue
FROM payment p
INNER JOIN rental r ON r.rental_id = p.rental_id
INNER JOIN inventory i ON i.inventory_id = r.inventory_id
INNER JOIN film_category fc ON fc.film_id = i.film_id
INNER JOIN category c ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY total_revenue DESC LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_profitable_genres AS

SELECT c.name, SUM(p.amount) AS total_revenue
FROM payment p
INNER JOIN rental r ON r.rental_id = p.rental_id
INNER JOIN inventory i ON i.inventory_id = r.inventory_id
INNER JOIN film_category fc ON fc.film_id = i.film_id
INNER JOIN category c ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY total_revenue DESC LIMIT 5;


-- 8b. How would you display the view that you created in 8a?
SHOW CREATE VIEW top_five_profitable_genres;


-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS top_five_profitable_genres;
