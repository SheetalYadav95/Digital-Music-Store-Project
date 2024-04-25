Create or replace view customer_info(Customer_id,
	Cust_Name,
	Cust_Country,
	Cust_Email,
	Invoice_id,
	Invoice_date,
    billing_country,
	Total_Sale,
	Invoice_line_id,
	Unit_price,
	Quantity,
	track_id,
	recency,
	frequency,
	Monetary,
	recency_score,
	Frequency_score,
	Monetary_score,
	rfm_score,
	rfm_segment)
	as(
	Select c.customer_id,
	Concat(trim(c.first_name),' ',trim(c.last_name)) as Cust_Name,
    c.country,
	c.email,
	i.invoice_id,
	i.invoice_date,
    i.billing_country,
	i.total,
	il.invoice_line_id,
	il.unit_price,
	il.quantity,
	il.track_id,
		rfm.recency,
		rfm.frequency,
		rfm.monetary,
		rfm.recency_score,
		rfm.frequency_score,
		rfm.monetary_score,
		rfm.rfm_score,
		rfm.rfm_segment
		from customer c Join invoice i on c.customer_id = i.customer_id
	    Join invoice_line il on i.invoice_id = il.invoice_id
		Join rfm_Analysis rfm on c.customer_id = rfm.customer_id
)


Create or replace view genre_media_info(
	Track_id,
	Track_name,
    Song_length,
	Song_size,
    Media_type_id,
    Media_name,
    Genre_id,
	Genre_name)
	as (
	Select t.track_id,
	t.name,
	t.milliseconds,
	t.bytes,
	m.media_type_id,
	m.name,
    g.genre_id,
	g.name
		from track t join genre g on t.genre_id = g.Genre_id
	join media_type m on t.media_type_id = m.media_type_id
 )
 
Create or replace view album_artist_info(
    Track_id,
	Track_name,
	Artist_id,
	Artist_name,
	Album_id,
    Album_title)
	as (
	select t.track_id,
	t.name,
	a.artist_id,
	a.name,
	al.album_id,
	al.title
	from track t join album al on t.album_id = al.album_id
    join artist a on al.artist_id = a.artist_id
	)

Create or replace view playlist_info(
	Playlist_id,
	Playlist_name,
	Track_id)
	as(
	select p.playlist_id,
	p.name,
	pt.track_id
	from playlist_track pt join playlist p on pt.playlist_id = p.playlist_id
	)
