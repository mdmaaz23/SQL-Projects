----------------------------------------- SET 1 -----------------------------------------------------------
select * from employee

--Q1)Who is the senior most employee based on job title?
select * from employee
WHERE reports_to is NULL
=============================================================================================================
--Q2)Which countries have the most Invoices?
select * from invoice

select billing_country,count(*) as i from invoice
group by billing_country 
order by i desc
=============================================================================================================
--3. What are top 3 values of total invoice?
select * from invoice

select * from invoice
order by total desc
limit 3
============================================================================================================
--4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we 
--made the most money. Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals
select * from invoice

select sum(total) invoice_totals , billing_city from invoice
group by billing_city
order by invoice_totals desc
limit 1
=============================================================================================================
--5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money
select * from customer
select * from invoice

select c.customer_id,c.first_name,c.last_name,sum(i.total) total
from customer c join invoice i 
on c.customer_id = i.customer_id
group by c.customer_id
order by total desc
limit 1
============================================================================================================
-------------------------------------------- SET 2 --------------------------------------------------------------
--1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list
--ordered alphabetically by email starting with A
select * from genre

select c.email,c.first_name,c.last_name,g.name
from 
	customer c 
join 
	invoice i on c.customer_id = i.customer_id
join 
	invoice_line il on i.invoice_id = il.invoice_id
join 
	track t on il.track_id = t.track_id
join 
	genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
AND c.email like 'a%'
order by c.email asc

--2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the
--Artist name and total track count of the top 10 rock bands
select * from track
select * from genre

select a.name,count(t.track_id) total_track
from 
	artist a 
join 
	album al on a.artist_id = al.artist_id
join 
	track t on al.album_id = t.album_id
join 
	genre g on t.genre_id = g.genre_id

where g.name = 'Rock'
group by a.name
order by total_track desc
limit 10

--3. Return all the track names that have a song length longer than the average song length. Return the Name and 
--Milliseconds for each track. Order by the song length with the longest songs listed first
select * from track

select name,milliseconds from track
where milliseconds > (select avg(milliseconds) track_length
					  from track 
					 )
order by milliseconds desc
===============================================================================================================
---------------------------------------------- Set 3 ----------------------------------------------------------
--1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name 
--and total spent
SELECT 
    c.First_Name || ' ' || c.Last_Name AS CustomerName,
    ar.Name AS ArtistName,
    SUM(il.Unit_Price * il.Quantity) AS TotalSpent  --We calculate the total amount spent by multiplying UnitPrice by Quantity and summing up the results
FROM 
    Customer c
JOIN 
    Invoice i ON c.customer_Id = i.Customer_Id
JOIN 
    Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
JOIN 
    Track t ON il.Track_Id = t.Track_Id
JOIN 
    Album al ON t.Album_Id = al.Album_Id
JOIN 
    Artist ar ON al.Artist_Id = ar.Artist_Id
GROUP BY c.First_Name, c.Last_Name, ar.Name
ORDER BY CustomerName, ArtistName;


--2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the
--genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres

--Using Common Table Expression (CTE) GenrePopularity
WITH GenrePopularity AS (
    SELECT 
        cu.Country,
        g.Name AS GenreName,
        SUM(il.Unit_Price * il.Quantity) AS TotalSpent,
        ROW_NUMBER() OVER (PARTITION BY cu.Country ORDER BY SUM(il.Unit_Price * il.Quantity) DESC) AS RowNum,
        RANK() OVER (PARTITION BY cu.Country ORDER BY SUM(il.Unit_Price * il.Quantity) DESC) AS RankNum
    FROM 
        Customer cu
    JOIN 
        Invoice i ON cu.Customer_Id = i.Customer_Id
    JOIN 
        Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
    JOIN 
        Track t ON il.Track_Id = t.Track_Id
    JOIN 
        Genre g ON t.Genre_Id = g.Genre_Id
    GROUP BY 
        cu.Country, g.Name
)
SELECT 
    Country,
    GenreName,
    TotalSpent
FROM 
    GenrePopularity
WHERE 
    RankNum = 1
ORDER BY 
    Country, GenreName;


--3. Write a query that determines the customer that has spent the most on music for each country. Write a query 
--that returns the country along with the top customer and how much they spent. For countries where the top amount
--spent is shared, provide all customers who spent this amount
--Method 1:-
WITH CustomerSpending AS (
    SELECT 
        cu.Country,
        cu.Customer_Id,
        cu.First_Name || ' ' || cu.Last_Name AS CustomerName,
        SUM(il.Unit_Price * il.Quantity) AS TotalSpent,
        RANK() OVER (PARTITION BY cu.Country ORDER BY SUM(il.Unit_Price * il.Quantity) DESC) AS RankNum
    FROM 
        Customer cu
    JOIN 
        Invoice i ON cu.Customer_Id = i.Customer_Id
    JOIN 
        Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
    GROUP BY 
        cu.Country, cu.Customer_Id, cu.First_Name, cu.Last_Name
)
SELECT 
    Country,
    CustomerName,
    TotalSpent
FROM 
    CustomerSpending
WHERE 
    RankNum = 1
ORDER BY 
    Country, CustomerName;
	







