-- =========================================================
-- PROJECT 2: PAGILA BUSINESS & SALES ANALYSIS
-- Database: Pagila
-- Tool: PostgreSQL / pgAdmin
-- =========================================================

SET search_path TO public;

-- 1. DATABASE SETUP & EXPLORATION:
--Q1. List all tables and the views available in the public schema.
select table_name
from information_schema.tables
where table_schema='public'
order by table_name;


--Q2.Count the records in each object listed in the public schema.
SELECT COUNT(*) FROM actor;

SELECT COUNT(*) FROM actor_info;

SELECT COUNT(*) FROM address;

SELECT COUNT(*) FROM category;

SELECT COUNT(*) FROM city;

SELECT COUNT(*) FROM country;

SELECT COUNT(*) FROM customer;

SELECT COUNT(*) FROM customer_list;

SELECT COUNT(*) FROM family_films;

SELECT COUNT(*) FROM film;

SELECT COUNT(*) FROM film_actor;

SELECT COUNT(*) FROM film_category;

SELECT COUNT(*) FROM film_list;

SELECT COUNT(*) FROM films_per_customer_rental;

SELECT COUNT(*) FROM inventory;

SELECT COUNT(*) FROM language;

SELECT COUNT(*) FROM payment;

SELECT COUNT(*) FROM payment_p0000_default;

SELECT COUNT(*) FROM payment_p2007_01;

SELECT COUNT(*) FROM payment_p2007_02;

SELECT COUNT(*) FROM payment_p2007_03;

SELECT COUNT(*) FROM payment_p2007_04;

SELECT COUNT(*) FROM payment_p2007_05;

SELECT COUNT(*) FROM payment_p2007_06;

SELECT COUNT(*) FROM payment_p2007_07_max;

SELECT COUNT(*) FROM rental;

SELECT COUNT(*) FROM rental_report;

SELECT COUNT(*) FROM sales_by_film_category;

SELECT COUNT(*) FROM sales_by_store;

SELECT COUNT(*) FROM sales_top5_by_film_category;

SELECT COUNT(*) FROM staff;

SELECT COUNT(*) FROM staff_list;

SELECT COUNT(*) FROM store;


-- 2.CUSTOMER ANALYSIS:
--Q3.Find the total number of customers.
select count(customer_id) 
from customer;


--Q4.Calculate the total spending of each customer.
select sum(amount),customer_id
from payment
group by customer_id;


-- Q5. Find the top 10 customers by total spending.
select customer_id,sum(amount)
as total_spending from payment
group by customer_id
order by total_spending desc
limit 10;


-- Q6.Find the top 10 customers by total rental transactions.
select c.customer_id,c.first_name,c.last_name,
count(r.rental_id) as total_rentals 
from customer c 
inner join rental r
on c.customer_id=r.customer_id
group by c.customer_id,c.first_name,c.last_name
order by total_rentals desc
limit 10;


-- Q7. Find the latest rental start date for each customer.
select c.customer_id,c.first_name,c.last_name,
max(lower(r.rental_period)) as latest_rental_period 
from customer c
left join rental r 
on c.customer_id=r.customer_id
group by c.customer_id,c.first_name,c.last_name 
order by latest_rental_period desc nulls last;


-- Q8. Find the earliest rental start date for each customer.
select c.customer_id,c.first_name,c.last_name,
min(lower(r.rental_period)) as first_rental_period 
from customer c
left join rental r 
on c.customer_id=r.customer_id
group by c.customer_id,c.first_name,c.last_name 
order by first_rental_period asc nulls last;


-- Q9.Calculate the number of days between each customer's
--      first and last rental.
select c.customer_id,c.first_name,c.last_name,
min(lower(r.rental_period)) as first_rental_date,
max(lower(r.rental_period)) as latest_rental_date,
max(lower(r.rental_period))::date
			-min(lower(r.rental_period)):: date as days_between
from customer c 
left join rental r 
on c.customer_id=r.customer_id
group by c.customer_id,c.first_name,c.last_name
order by days_between desc nulls last;


-- Q10.Find customers whose total spending is above the
--      average total spending per customer.
select customer_id,sum(amount) as total_spending 
from payment
group by customer_id
having sum(amount)>(
select avg(customer_total)
from (
select sum(amount) as customer_total
from payment
group by customer_id
) as customer_spending 
)
order by total_spending desc;


-- Q11. Find customers whose rental transaction count is
--      above the average rental count per customer.
select c.customer_id,c.first_name,c.last_name,
count(r.rental_id) as total_rentals 
from customer c 
left join rental r
on c.customer_id=r.customer_id
group by c.customer_id,c.first_name,c.last_name 
having count(r.rental_id) >(
select avg(customer_rental_count) 
from (
select c2.customer_id,
count(r2.rental_id) as customer_rental_count
from customer c2 
left join rental r2 
on c2.customer_id=r2.customer_id
group by c2.customer_id
)as rental_counts

)
order by total_rentals desc;


-- Q12. Count the distinct films rented by each customer.
select c.customer_id,c.first_name,c.last_name,
count(distinct i.film_id) as distinct_films_rented
from customer c 
left join rental r 
on c.customer_id=r.customer_id
left join inventory i 
on r.inventory_id=i.inventory_id
group by c.customer_id,c.first_name,c.last_name
order by distinct_films_rented desc;


-- Q13.Find the top three highest-spending customers
--      in each country.
with customer_spending as(
select 
co.country,
c.first_name,
c.last_name,
c.customer_id,
sum(p.amount) as total_spending
from customer c 
inner join payment p
on c.customer_id=p.customer_id
inner join address a 
on c.address_id=a.address_id
inner join city ci
on a.city_id=ci.city_id
inner join country co
on ci.country_id=co.country_id
group by 
co.country,
c.first_name,
c.last_name,
c.customer_id
),
ranked_customers as (
select 
country,
customer_id,
first_name,
last_name,
total_spending,
row_number() over(
partition by country
order by total_spending desc,customer_id
)as customer_rank
from customer_spending
)
select 
country,
first_name,
last_name,
total_spending,
customer_rank
from ranked_customers
where customer_rank<=3
order by country,customer_rank;


-- Q14.Find customers who rented from both stores.
select c.customer_id,c.first_name,c.last_name,
count(distinct i.store_id) as distinct_stores
from customer c 
inner join rental r 
on c.customer_id=r.customer_id
inner join inventory i
on r.inventory_id=i.inventory_id
group by c.customer_id,c.first_name,c.last_name
having count(distinct i.store_id) =2
order by c.customer_id;


-- 3.RENTAL ANALYSIS:
--Q15.Find the total number of rental transactions.
select count(rental_id)
from rental;


-- Q16.Calculate monthly rental counts and compare each
--      month's count with the previous row using LAG().
with monthly_rentals as (
select date_trunc('month',lower(r.rental_period)) as rental_month,
count(*) as total_rentals
from rental r
group by date_trunc('month',lower(r.rental_period))
),
rental_changes as(
select rental_month,total_rentals,lag(total_rentals) over(
order by rental_month
)as previous_month_rentals 
from monthly_rentals 
)
select rental_month,total_rentals ,previous_month_rentals,
total_rentals-previous_month_rentals as change_from_previous_month
from rental_changes
order by rental_month;


-- Q17.Find each customer's previous rental date and
--      calculate the gap in days between rentals.
with customer_rentals as (
select 
customer_id,
lower(rental_period) as rental_start
from rental
),
rental_history as (
select 
customer_id,
rental_start,
lag(rental_start) over(
partition by customer_id
order by rental_start
)as previous_rental_start
from customer_rentals 
)
select 
c.customer_id,
c.first_name,
c.last_name,
rh.rental_start,
rh.previous_rental_start,
rh.rental_start::date-
rh.previous_rental_start:: date as days_between_rentals
from rental_history rh
inner join customer c 
on rh.customer_id=c.customer_id
order by c.customer_id,rh.rental_start;


-- Q18.Find rentals whose actual duration exceeded
--      the film's allowed rental duration.
select r.customer_id,f.title,
lower(r.rental_period) as rental_start_date,
upper(r.rental_period) as rental_end_date,
f.rental_duration as allowed_rental_days,
round( 
(
extract( epoch from(
upper(r.rental_period)-lower(r.rental_period)
)
)/86400.0
):: numeric,
2
) as actual_rental_duration_days
from rental r
inner join inventory i
on r.inventory_id=i.inventory_id
inner join film f 
on i.film_id=f.film_id
where upper(r.rental_period) is not null
and(
upper(r.rental_period)-lower(r.rental_period)
)> f.rental_duration*INTERVAL '1 day'
order by actual_rental_duration_days desc;


-- 4.FILM ANALYSIS:
--Q19. Find the total number of films.
select count(film_id)
from film;


-- Q20. Find the five most-rented films.
select f.title,
count(r.rental_id) as total_rentals
from film f 
inner join inventory i 
on f.film_id=i.film_id
inner join rental r
on i.inventory_id=r.inventory_id
group by f.title ,f.film_id
order by total_rentals desc
limit 5;


-- Q21.Identify films that have inventory copies
--      without a corresponding rental record.
select f.film_id,f.title
from film f 
inner join inventory i 
on f.film_id=i.film_id
left join rental r 
on i.inventory_id=r.inventory_id
where r.rental_id is null;


-- Q22. Classify films as Short, Medium, or Long based
--      on their running time.
select 
	case
		when length <90 then 'short'
		when length between 90 and 120 then 'medium'
		else 'long'
		end as film_length_category,
		count(film_id) as total_films 
from film
group by film_length_category
order by total_films;


-- Q23.Find the 10 films with the highest replacement cost.
select title,replacement_cost,rental_rate 
from film 
order by replacement_cost desc
limit 10;


-- Q24.Calculate the number of films and average rental
--      rate for each language.
select l.name as language_name,
count(f.film_id) as total_films,
avg(f.rental_rate) as avg_rental_rate
from film f 
inner join language l
on f.language_id=l.language_id
group by l.language_id ,l.name 
order by total_films desc;


-- Q25. Calculate the average film length for each rating.
select rating,avg(length) as avg_film_length
from film 
group by rating 
order by avg_film_length desc;


-- Q26.Find the top 10 actors who appeared in the most films.
select a.first_name,a.last_name,count(fa.film_id) as total_films
from actor a 
inner join film_actor fa 
on a.actor_id=fa.actor_id
group by a.actor_id,a.first_name,a.last_name
order by total_films desc
limit 10;


-- Q27. Find the 10 films with the most inventory copies.
select f.title,
count(i.inventory_id) as total_copies
from film f 
inner join inventory i 
on f.film_id=i.film_id
group by f.film_id,f.title
order by total_copies desc
limit 10;


-- Q28.Find films rented more times than the average
--      rental count per film.
select f.film_id,f.title,
count(r.rental_id) as total_rentals
from film f 
left join inventory i
on f.film_id=i.film_id
left join rental r
on i.inventory_id=r.inventory_id
group by f.film_id,f.title
having count(r.rental_id)>(
select avg(film_rental_count)
from (
select 
f2.film_id,count(r2.rental_id) as film_rental_count
from film f2 
left join inventory i2
on f2.film_id=i2.film_id
left join rental r2
on i2.inventory_id=r2.inventory_id
group by f2.film_id 
) as rental_counts
)
order by total_rentals desc;


-- Q29. Find films whose rental rate is above the average
--      rental rate for their rating.
with film_rates as (
select 
title,rating,rental_rate,
avg(rental_rate) over(
partition by rating
) as average_rating_rental_rate
from film
)
select title,rating,rental_rate,
round(average_rating_rental_rate,2)
as average_rating_rental_rate
from film_rates
where rental_rate>average_rating_rental_rate
order by rating,rental_rate desc;


-- 5.CATEGORY ANALYSIS:
-- Q30. Calculate total revenue generated by each category.
select c.name as category_name,
sum(amount) as total_revenue
from payment p
inner join rental r
on p.rental_id=r.rental_id
inner join inventory i
on r.inventory_id=i.inventory_id
inner join film f
on i.film_id=f.film_id
inner join film_category fc
on f.film_id=fc.film_id
inner join category c 
on fc.category_id=c.category_id
group by c.name
order by total_revenue desc;


-- Q31. Find the top five categories by rental count.
select c.name as category_name , count(r.rental_id)
as total_rentals 
from category c 
inner join film_category fc 
on c.category_id=fc.category_id
inner join inventory i 
on fc.film_id=i.film_id
inner join rental r 
on i.inventory_id=r.inventory_id
group by c.category_id ,c.name 
order by total_rentals desc
limit 5;


-- Q32. Find the top three most-rented films within
--      each category.
with film_rentals as (
select c.name as category_name,
f.film_id,
f.title,
count(r.rental_id) as total_rentals 
from category c 
inner join film_category fc 
on c.category_id=fc.category_id
inner join film f 
on fc.film_id=f.film_id
inner join inventory i 
on f.film_id=i.film_id
inner join rental r 
on i.inventory_id=r.inventory_id
group by c.name,f.film_id,f.title 
),
ranked_films as (
select category_name,
title,total_rentals ,row_number() over(
partition by category_name 
order by total_rentals desc,title 
) as film_rank
from film_rentals 

)
select category_name,title,total_rentals,film_rank 
from ranked_films 
where film_rank<=3
order by category_name,film_rank;


-- Q33. Calculate the average allowed rental duration
--      for films in each category.
select c.name as category_name,
round(avg(f.rental_duration),2)as avg_rental_duration_days
from category c
inner join film_category fc 
on c.category_id=fc.category_id
inner join film f
on fc.film_id=f.film_id
group by c.category_id,c.name
order by avg_rental_duration_days desc;


-- Q34.Calculate total revenue, rental count, and average
--      revenue per rental for each category.
select 
c.name as category_name,
sum(p.amount) as total_revenue,
count(distinct r.rental_id) as total_rentals,
round(
sum(p.amount)/ count(distinct r.rental_id),2
) as average_revenue_per_rental
from category c
inner join film_category fc
on c.category_id=fc.category_id
inner join inventory i
on fc.film_id=i.film_id
inner join rental r
on i.inventory_id=r.inventory_id
inner join payment p
on r.rental_id=p.rental_id
group by c.category_id,c.name
order by average_revenue_per_rental desc;


-- 6.REVENUE ANALYSIS:
--Q35. Calculate total revenue generated by the business.
select sum(amount) from payment;


--Q36.Calculate the average payment amount.
select avg(amount)
from payment;


--Q37. Find the highest payment amount.
select max(amount) from payment;


--Q38.Find the lowest payment amount.
select min(amount) from payment;


--Q39.Count the total number of payment records.
select count(amount) from payment;


-- Q40.Calculate total revenue generated by each film rating.
select f.rating,sum(p.amount) as total_revenue
from payment p 
inner join rental r 
on p.rental_id=r.rental_id
inner join inventory i 
on r.inventory_id=i.inventory_id
inner join film f 
on i.film_id=f.film_id
group by f.rating 
order by total_revenue desc;


-- Q41.Calculate monthly revenue and cumulative revenue.
with monthly_revenue as (
select 
date_trunc('month',p.payment_date) as revenue_month,
sum(p.amount) as monthly_revenue
from payment p
group by date_trunc('month',p.payment_date)
)
select revenue_month,monthly_revenue,
sum(monthly_revenue) over(
order by revenue_month
)as cumulative_revenue
from monthly_revenue
order by revenue_month;


-- 42.Calculate total revenue generated by each country.
select 
co.country,sum(p.amount) as total_revenue
from payment p
inner join customer c 
on p.customer_id=c.customer_id
inner join address a
on c.address_id=a.address_id
inner join city ci
on a.city_id=ci.city_id
inner join country co 
on ci.country_id=co.country_id
group by co.country_id,co.country
order by total_revenue desc;



-- 7.STAFF & STORE ANALYSIS:
-- Q43.Calculate the total revenue generated by each staff member.
select staff_id,sum(amount) as total_revenue
from payment 
group by staff_id
order by total_revenue desc;


-- Q44.Count the number of payment records handled
--      by each staff member.
SELECT staff_id,COUNT(payment_id) AS total_payments
FROM payment
GROUP BY staff_id
ORDER BY total_payments DESC;


-- Q45.Calculate total revenue generated by each store.
select i.store_id,sum(p.amount) as total_revenue
from payment p 
inner join rental r 
on p.rental_id=r.rental_id
inner join inventory i 
on r.inventory_id=i.inventory_id
group by i.store_id
order by total_revenue desc;


-- Q46.Count the customers associated with each store.
select store_id,count(customer_id) as total_customers 
from customer 
group by store_id
order by total_customers desc;


-- Q47.Count the inventory copies held by each store.
select store_id,count(inventory_id) total_copies 
from inventory 
group by store_id
order by total_copies desc;


-- Q48.Count rental transactions associated with each store.
select i.store_id,count(r.rental_id) as total_rentals 
from rental r 
inner join inventory i 
on r.inventory_id=i.inventory_id
group by i.store_id
order by total_rentals desc;


-- Q49.Calculate each store's percentage contribution
--      to total business revenue.
with store_revenue as (
select i.store_id,sum(p.amount) as total_revenue 
from payment p 
inner join rental r 
on p.rental_id=r.rental_id
inner join inventory i 
on r.inventory_id=i.inventory_id
group by i.store_id
)
select store_id,total_revenue,
round(total_revenue*100.0/sum(total_revenue) over(),2)
as revenue_percentage
from store_revenue
order by total_revenue desc;


-- Q50. Find the highest-revenue category within each store.
with store_category_revenue as (
select i.store_id ,c.name as category_name,
sum(p.amount) as total_revenue
from payment p
inner join rental r 
on p.rental_id=r.rental_id
inner join inventory i 
on r.inventory_id=i.inventory_id
inner join film_category fc 
on i.film_id=fc.film_id
inner join category c 
on fc.category_id=c.category_id
group by 
i.store_id,c.name,c.category_id
),
ranked_categories as (
select 
store_id,
category_name,
total_revenue,
rank() over(
partition by store_id
order by total_revenue desc
) as category_rank
from store_category_revenue
)
select 
store_id,
category_name,
category_rank
from ranked_categories 
where category_rank=1
order by store_id;


