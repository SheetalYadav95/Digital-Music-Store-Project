-- 1. Who is the senior most employee based on job title?

Select first_name, last_name, levels, Employee_id from Employee order by levels desc limit 1

--2. Which countries have the most Invoices?

select billing_country, count(*) as total from invoice group by billing_country
order by total desc

--3. What are top 3 values of total invoice?

select total from invoice order by total desc limit 3

--4. Which city has the best customers? 
(We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals)

select billing_city , sum(total) as total_purchase from invoice group by billing_city
order by total_purchase Desc

-- 5. Who is the best customer? 
(The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money)

select customer.first_name, customer.last_name, sum(invoice.total) as total_purchase from customer
join invoice on customer.customer_id = invoice.customer_id 
group by customer.first_name, customer.last_name
order by total_purchase Desc
limit 1

-- 6. Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with A

--Method 1
Select Distinct (customer.email) as email, customer.first_name, customer.last_name from customer 
join invoice on customer.customer_id = invoice.Customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
order by email
--Method 2
Select Distinct(customer.email) as email, customer.first_name, customer.last_name from customer 
join invoice on customer.customer_id = invoice.Customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id  IN (select track_id from track 
join genre on track.genre_id = genre.genre_id where genre.name like 'Rock')
order by email

-- 7. Let's invite the artists who have written the most rock music in our dataset. 
--(Write a query that returns the Artist name and total track count of the top 10 rock bands)

Select artist.artist_id,artist.name, count(genre.name) as track_count 
from artist join album
on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id,artist.name
order by track_count Desc
limit 10

--8. Return all the track names that have a song length longer than the average song length. 
--(Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first)
--From Table--
Select name, milliseconds as song_length from track 
where milliseconds > (select Avg(milliseconds) from track)
order by song_length Desc

--9. Find how much amount spent by each customer on artists? 
--(Write a query to return customer name, artist name and total spent)

With Amount_spend as (
Select customer.first_name as First_Name,customer.last_name as Last_Name, artist.name, 
sum(invoice_line.unit_price*invoice_line.quantity) as TAS
from customer join invoice on customer.customer_id = invoice.Customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by First_Name, Last_Name, artist.name
order by First_Name Asc,Last_Name Asc,TAS Desc
)
Select * from Amount_spend

--10. Find how much amount spent by each customer on Top artist(in terms of sale)? 
--(Write a query to return customer name, artist name and total spent)

with top_artist as (select artist.artist_id as Artist_id,artist.name as Artist_name, 
sum(invoice_line.unit_price*invoice_line.quantity) as TAS
from invoice_line join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by 1,2
order by 3 Desc 
limit 1)
Select customer.first_name, customer.last_name,top_artist.Artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as Total from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join top_artist on album.artist_id = top_artist.artist_id
group by 1,2,3
order by 4 Desc


--11. We want to find out the most popular music Genre for each country.
--(We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres)

--Method 1
With Popular_music as (
	Select invoice.billing_country, genre.name, count(invoice_line.quantity) as total_purchase,
	row_number() over(partition by invoice.billing_country order by count(invoice_line.quantity) Desc)
	as RowNo from invoice join invoice_line on invoice.invoice_id = invoice_line.invoice_id
    join track on invoice_line.track_id = track.track_id
	join genre on track.genre_id = genre.genre_id
	group by 1,2
	order by 1 asc,3 Desc
	)
	select * from Popular_music where RowNo <=1

--Method 2 (Recursive)
with Recursive popular_music as (Select invoice.billing_country as country, genre.name as genre_name,
								 count(invoice_line.quantity) as total_purchase
								from invoice join invoice_line 
								 on invoice.invoice_id = invoice_line.invoice_id
    join track on invoice_line.track_id = track.track_id
	join genre on track.genre_id = genre.genre_id
								group by 1,2
								order by 1, 3 Desc
								),
Max_purchased_genre as (select country,Max(total_purchase) as Max_purchase 
						from popular_music 
					   group by 1
					   order by 2 Desc
						)
Select popular_music.* from popular_music join Max_purchased_genre
on popular_music.country = Max_purchased_genre.country
where popular_music.total_purchase = Max_purchased_genre.Max_purchase


--12. Write a query that determines the customer that has spent the most on music for each country. 
(Write a query that returns the country along with the top customer and how much they spent. 
 For countries where the top amount spent is shared, provide all customers who spent this amount)
-- If Music refers to the Music from playlist

--Method 1
With spent_on_music as (
     Select playlist.name as Playtrack, customer.country, customer.first_name, customer.last_name,
	 sum(invoice_line.unit_price*invoice_line.quantity) as Total_spend,
	 row_number() over(partition by customer.country 
	 order by sum(invoice_line.unit_price* invoice_line.quantity) Desc) as Rowno
	 from playlist
     join playlist_track on playlist.playlist_id = playlist_track.playlist_id
     join invoice_line on playlist_track.track_id = invoice_line.track_id
	 join invoice on invoice_line.invoice_id = invoice.invoice_id
	 join customer on invoice.customer_id = customer.customer_id
	 where playlist.name = 'Music'
	 group by 1,2,3,4
	 order by 5 Desc
	)
	Select * from spent_on_music where rowno<=1 order by country
	
--Method 2
With Recursive spent_on_music as (Select customer.country as country, customer.first_name, customer.last_name,
								 sum(invoice_line.unit_price*invoice_line.quantity) as total_spent,playlist.name from playlist
     join playlist_track on playlist.playlist_id = playlist_track.playlist_id
     join invoice_line on playlist_track.track_id = invoice_line.track_id
	 join invoice on invoice_line.invoice_id = invoice.invoice_id
	 join customer on invoice.customer_id = customer.customer_id
								 where playlist.name ='Music'
								 group by 1,2,3,5
								 order by 4 Desc
								 ),
Max_spend as (select country, max(total_spent)as Max_spent from spent_on_music
			 group by 1
			 order by 2 Desc)
Select spent_on_music.* from spent_on_music join Max_spend
on spent_on_music.country = Max_spend.country
where spent_on_music.total_spent = Max_spend.Max_spent

--If Music refers to all categories

--Method 1
With spent_on_music as (
     Select customer.country, customer.first_name, customer.last_name,
	 sum(invoice_line.unit_price*invoice_line.quantity) as Total_spend,
	 row_number() over(partition by customer.country 
	 order by sum(invoice_line.unit_price* invoice_line.quantity) Desc) as Rowno
	 from invoice_line
	 join invoice on invoice_line.invoice_id = invoice.invoice_id
	 join customer on invoice.customer_id = customer.customer_id
	 group by 1,2,3
	 order by 4 Desc
	)
	Select * from spent_on_music where rowno<=1 order by country

--Method 2
With Recursive spent_on_music as (Select customer.country as country, customer.first_name, customer.last_name,
								 sum(invoice_line.unit_price*invoice_line.quantity) as total_spent from invoice_line 
	 join invoice on invoice_line.invoice_id = invoice.invoice_id
	 join customer on invoice.customer_id = customer.customer_id
								 group by 1,2,3
								 order by 4 Desc
								 ),
Max_spend as (select country, max(total_spent)as Max_spent from spent_on_music
			 group by 1
			 order by 2 Desc)
Select spent_on_music.* from spent_on_music join Max_spend
on spent_on_music.country = Max_spend.country
where spent_on_music.total_spent = Max_spend.Max_spent
order by country

--13. Most purchased playlist

Select Playlist.name, sum(invoice_line.quantity) as total_purchased from playlist
join playlist_track on playlist.playlist_id = playlist_track.playlist_id
join invoice_line on playlist_track.track_id = invoice_line.track_id
group by 1
order by 2 Desc

--Sales Analysis Task:
--Extract data from the Invoice table to analyze total sales revenue by country for the past quarter.
Select invoice.billing_country, sum(total) as Total_revenue
from invoice group by 1 
order by 2 Desc
--Calculate the average order value for each country.
Select invoice.billing_country, Avg(total) as AOV
from invoice
group by 1 
order by 2 Desc 
--Identify the top-selling genres and artists based on the total sales amount
1.
With Top_selling as (Select genre.name as Genre_name,artist.name as Artist_name ,sum(invoice_line.unit_price*invoice_line.quantity) as Total_Sale,
row_number() over (partition by genre.name order by sum(invoice_line.unit_price*invoice_line.quantity) Desc
				   ) as Rowno
from artist join album
on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
join invoice_line on track.track_id = invoice_line.track_id
group by 1,2
order by 3 Desc )
Select * from Top_selling where rowno<=1
2.
Select  genre.name,artist.name,sum(invoice_line.unit_price*invoice_line.quantity) as Total_Sale
from artist join album
on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
join invoice_line on track.track_id = invoice_line.track_id
group by 1,2
order by 3 Desc 

--Employee Performance Task:

--Evaluate the performance of sales support representatives using data from the Employee and Invoice tables.
Select concat(trim(employee.first_name),
			  trim(employee.last_name)), 
			  sum(invoice.total) as total_sale 
			  from employee
join customer on cast(employee.employee_id as Int) = customer.support_rep_id
join invoice on customer.customer_id = invoice.customer_id
group by 1
order by 2 Desc
--Calculate metrics such as total sales generated, average order size for each representative.
Select concat(trim(employee.first_name),
			  trim(employee.last_name)), 
			  sum(invoice_line.unit_price*invoice_line.quantity) as Total_sale,
			  Avg(invoice_line.quantity) as AOS
from employee join customer on cast(employee.employee_id as Int) = customer.support_rep_id
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
group by 1
order by 2 Desc

--Inventory Management Task:

--Identify top-selling tracks and albums to optimize inventory stocking levels.
Select track.name as track_name, 
album.title as Album_name,
sum(invoice_line.quantity) as Total_quantity_sold
from album join track on album.album_id = track.album_id
join invoice_line on track.track_id = invoice_line.track_id
group by 1,2
order by 3 Desc

--Identify top-selling tracks to optimize inventory stocking levels.
Select track.name as track_name,
sum(invoice_line.quantity) as Total_quantity_sold
from track join invoice_line on track.track_id = invoice_line.track_id
group by 1
order by 2 Desc
--Identify top-selling albums to optimize inventory stocking levels.
Select album.title as Album_name,
sum(invoice_line.quantity) as Total_quantity_sold
from album join track on album.album_id = track.album_id
join invoice_line on track.track_id = invoice_line.track_id
group by 1
order by 2 Desc

--Here's an outline for a project that involves SQL ETL (Extract, Transform, Load) processes 
--and Power BI visualization for customer segmentation and lifetime value analysis:

1. Simple Data Extraction:

--Extract customer information including customer ID, purchase history, and demographics.
Select customer_id, 
billing_country,
invoice_date as Purchase_history 
from invoice order by 1
--Extract invoice data including invoice ID, customer ID, purchase date, and purchase details (track ID, unit price, quantity).
Select i.invoice_id, 
i.customer_id, 
i.invoice_date as Purchase_date,
il.track_id, 
il.unit_price, 
il.quantity
from invoice i join invoice_line il 
on i.invoice_id = il.invoice_id
--Extract track and album information including track ID, album ID, genre, composer, and duration.
Select t.track_id,
t.album_id,
t.composer,
g.name,
t.milliseconds as Duration
from track t join genre g 
on t.genre_id = g.genre_id

--Data Transformation:

--Calculate customer purchase frequency, recency, and monetary value based on their purchase history.
--RFM Analysis

With rfm as (
	select customer_id, 
       max(invoice_date) as last_order_date,
	   ('2021-01-01' - max(invoice_date)) as Recency,
       count(*) as Frequency,
       Cast(Sum(total) as decimal(16,0)) as Monetary
from invoice
	group by 1
	),
	rfm_percentile as (
select customer_id, 
Recency,
Frequency,
Monetary,
       ntile(3) over (order by Recency desc) as recency_score,
       ntile(3) over (order by Frequency) as frequency_score,
       ntile(3) over (order by Monetary) as monetary_score
from rfm
	),
rfm_total as (
	Select rfm_percentile.customer_id,
	(recency_score + frequency_score + monetary_score) as rfm_score,
	count(rfm_percentile.customer_id) as Total_customers,
	sum(rfm.Monetary) as total_revenue
	from rfm_percentile join rfm
	on rfm.customer_id = rfm_percentile.customer_id
	group by 1,2
	order by 1 Desc
	)
	Select rp.Customer_id,
	rp.recency_score,
	rp.frequency_score,
	rp.monetary_score,
	case
	when rt.rfm_score in (3,4) then 'Low value customers'
	when rt.rfm_score in (5,6,7) then 'Medium value customers'
	when rt.rfm_score in (8,9) then 'High value customers'
	end rfm_segment
from rfm_total rt join rfm_percentile rp
	on rt.customer_id = rp.customer_id

--RFM Analysis in a table (capture RFM result in a table):

create table RFM_Analysis as (
With rfm_value as (
	select customer_id, 
       max(invoice_date) as last_order_date,
	   ('2021-01-01' - max(invoice_date)) as Recency,
       count(*) as Frequency,
       Cast(Sum(total) as decimal(16,0)) as Monetary
from invoice
	group by 1
	),
	rfm_percentile as (
select customer_id, 
Recency,
Frequency,
Monetary,
       ntile(3) over (order by Recency desc) as recency_score,
       ntile(3) over (order by Frequency) as frequency_score,
       ntile(3) over (order by Monetary) as monetary_score
from rfm_value
	),
rfm_total as (
	Select rfm_percentile.customer_id,
	(recency_score + frequency_score + monetary_score) as rfm_score,
	count(rfm_percentile.customer_id) as Total_customers,
	sum(rfm_value.Monetary) as total_revenue
	from rfm_percentile join rfm_value
	on rfm_value.customer_id = rfm_percentile.customer_id
	group by 1,2
	order by 1 Desc
	)
	Select rp.Customer_id,
	rp.Recency,
	rp.frequency,
	rp.Monetary,
	rp.recency_score,
	rp.frequency_score,
	rp.monetary_score,
	rt.rfm_score,
	case
	when rt.rfm_score in (3,4) then 'Low value customers'
	when rt.rfm_score in (5,6,7) then 'Medium value customers'
	when rt.rfm_score in (8,9) then 'High value customers'
	end rfm_segment
from rfm_total rt join rfm_percentile rp
	on rt.customer_id = rp.customer_id)
	
Select * from rfm_Analysis

	
