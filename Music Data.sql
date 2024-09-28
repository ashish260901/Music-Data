-- Q1. Who is the senior most employee based on job title?
SELECT 
    *
FROM
    employee
ORDER BY levels DESC
LIMIT 1;

-- Q.2. Which countries have the most invoices?
SELECT 
    COUNT(*) AS c, billing_country
FROM
    invoice
GROUP BY billing_country
ORDER BY c DESC;

-- Q.3. What are top 3 values of total invoices?
SELECT 
    total
FROM
    invoice
ORDER BY total DESC
LIMIT 3;

-- Q.4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals?
SELECT 
    SUM(total) AS invoice_total, billing_city
FROM
    invoice
GROUP BY billing_city
ORDER BY invoice_total DESC;

-- Q.5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money?
SELECT 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    SUM(invoice.total) AS total
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id , customer.first_name , customer.last_name
ORDER BY total DESC
LIMIT 1;

-- Q.6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.
SELECT name, revenue 
FROM (
    SELECT category, name, revenue, 
           RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
		SELECT pizza_types.category, pizza_types.name, 
               sum((order_details.quantity) * pizzas.price) AS revenue 
		FROM pizza_types JOIN pizzas ON pizza_types.﻿pizza_type_id = pizzas.pizza_type_id 
        JOIN order_details on order_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
	) AS a
) AS b 
WHERE rn <= 3;

-- Q.7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands?
SELECT 
    artist.artist_id,
    artist.name,
    COUNT(track.track_id) AS number_of_songs
FROM
    track
        JOIN
    album2 ON album2.album_id = track.album_id
        JOIN
    artist ON artist.artist_id = album2.artist_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name LIKE 'Rock'
GROUP BY artist.artist_id , artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

-- Q.8. Return all the track names that have a song length longer than the average song length.Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first?
SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds) AS avg_track_length
        FROM
            track)
ORDER BY milliseconds DESC;

-- Q.9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent?
WITH artist_sales AS (
    SELECT 
        artist.artist_id, 
        artist.name AS artist_name, 
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent_by_artist
    FROM 
        invoice_line
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        album2 ON album2.album_id = track.album_id
    JOIN 
        artist ON artist.artist_id = album2.artist_id
    GROUP BY 
        artist.artist_id, 
        artist.name
)

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    artist_sales.artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line ON i.invoice_id = invoice_line.invoice_id
        JOIN
    track ON track.track_id = invoice_line.track_id
        JOIN
    album2 ON album2.album_id = track.album_id
        JOIN
    artist_sales ON artist_sales.artist_id = album2.artist_id
GROUP BY c.customer_id , c.first_name , c.last_name , artist_sales.artist_id , artist_sales.artist_name
ORDER BY total_spent DESC;

-- Q.10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of 
-- purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
WITH popular_genre AS (
    SELECT 
        COUNT(invoice_line.quantity) AS purchases, 
        customer.country, 
        genre.name, 
        genre.genre_id, 
        ROW_NUMBER() OVER (
            PARTITION BY customer.country 
            ORDER BY COUNT(invoice_line.quantity) DESC
        ) AS RowNo
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
    ORDER BY customer.country ASC, purchases DESC
)

SELECT * 
FROM popular_genre 
WHERE RowNo <= 1;


-- Q.11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with 
-- the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
WITH Customer_with_country AS (
    SELECT 
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        customer.billing_country,
        SUM(invoice.total) AS total_spending,
        ROW_NUMBER() OVER (
            PARTITION BY customer.billing_country 
            ORDER BY SUM(invoice.total) DESC
        ) AS RowNo
    FROM 
        invoice
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    GROUP BY 
        customer.customer_id, 
        customer.first_name, 
        customer.last_name, 
        customer.billing_country
    ORDER BY 
        customer.billing_country ASC, 
        total_spending DESC
)
SELECT 
    * 
FROM 
    Customer_with_country 
WHERE 
    RowNo <= 1;