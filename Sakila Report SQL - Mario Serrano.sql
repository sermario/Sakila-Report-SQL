----FINANCIAL
--COMPANY REVENUES

select sum(AMOUNT) from payment;
select max(payment_date) from payment;

SELECT strftime('%Y',payment_date) as Year, strftime('%m',payment_date) as Month, round(SUM(AMOUNT),2) as TotalSales FROM PAYMENT 
GROUP BY strftime('%Y',payment_date),strftime('%m',payment_date) order by Year,Month;

select count(rental_id) from rental;

SELECT strftime('%Y',rental_date) as Year, strftime('%m',rental_date) as Month, count(rental_id) as TotalRentals FROM rental
GROUP BY strftime('%Y',rental_date),strftime('%m',rental_date) order by Year,Month;

--RENTALS PER STORE

select store.store_id, country.country, round(sum(payment.amount),2) as TotalSales from store
inner join address on store.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on country.country_id = city.country_id
inner join customer on store.store_id =customer.store_id 
inner join payment on customer.customer_id = payment.customer_id 
group by store.store_id;

--sales
SELECT store.store_id, strftime('%Y',payment_date) as Year, strftime('%m',payment_date) as Month, round(SUM(AMOUNT),2) as TotalSales from payment
inner join customer on payment.customer_id = customer.customer_id
inner join store on customer.store_id = store.store_id
where store.store_id=1
group by strftime('%Y',payment_date),strftime('%m',payment_date),store.store_id order by store.store_id,Year,Month;

SELECT store.store_id, strftime('%Y',payment_date) as Year, strftime('%m',payment_date) as Month, round(SUM(AMOUNT),2) as TotalSales from payment
inner join customer on payment.customer_id = customer.customer_id
inner join store on customer.store_id = store.store_id
where store.store_id=2
group by strftime('%Y',payment_date),strftime('%m',payment_date),store.store_id order by store.store_id,Year,Month;

--rentals
SELECT store.store_id, strftime('%Y',rental.rental_date) as Year, strftime('%m',rental.rental_date) as Month, count(rental.rental_id) as TotalRentals from rental
inner join customer on rental.customer_id = customer.customer_id
inner join store on customer.store_id = store.store_id
where store.store_id=1
group by strftime('%Y',rental.rental_date),strftime('%m',rental.rental_date),store.store_id order by store.store_id,Year,Month;

SELECT store.store_id, strftime('%Y',rental.rental_date) as Year, strftime('%m',rental.rental_date) as Month, count(rental.rental_id) as TotalRentals from rental
inner join customer on rental.customer_id = customer.customer_id
inner join store on customer.store_id = store.store_id
where store.store_id=2
group by strftime('%Y',rental.rental_date),strftime('%m',rental.rental_date),store.store_id order by store.store_id,Year,Month;
----CUSTOMERS

--total customers by create date
select strftime('%Y',create_date) as Year,strftime('%m',create_date) as Month,count(distinct(customer_id)) as TotalCustomers from customer
group by strftime('%Y',create_date),strftime('%m',create_date);

--uniaue customers
select strftime('%Y',mindate.FirstRentalDate) as Year,strftime('%m',mindate.FirstRentalDate) as Month,count(distinct(customer.customer_id)) as TotalCustomers 
from customer
inner join (select min(rental_date) as FirstRentalDate, customer_id from rental
            group by customer_id) as mindate on customer.customer_id = mindate.customer_id
group by strftime('%Y',mindate.FirstRentalDate),strftime('%m',mindate.FirstRentalDate);

--LAST PURCHASE

select max(payment_date) as LastPurchaseDate, (julianday('now')-max(julianday(payment_date)))/365 as TimeSince from payment;

-- average purchases(count) and spending($)
select Year,Month, round(avg(FreqPurch),2) as AvgFreqRent from
        (select  customer_id,strftime('%Y',rental_date) as Year,strftime('%m',rental_date) as Month, count(rental_id) as FreqPurch 
        from rental group by Year, Month,customer_id)
group by Year, Month;

select Year,Month, round(avg(SumSpent),2) as AvgSpent from
        (select  customer_id,strftime('%Y',payment_date) as Year,strftime('%m',payment_date) as Month, sum(amount) as SumSpent 
        from payment group by Year, Month,customer_id)
group by Year, Month;

--TENURE OF CUSTOMERS

select count(customer_id) as Customers, case when Active = 1 then 'Active' else 'Not Active' end as Active from customer
group by active;

--LOCATION OF CUSTOMERS

select count(country) from country;

select country.country, count(customer.customer_id) as Customers from customer
inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id
group by Country.country order by customers desc;

--top 10 total
select sum(Customers) from (select country.country, count(customer.customer_id) as Customers from customer
inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id
group by Country.country order by customers desc limit 10);


select country.country, round(sum(payment.amount),2) as TotalSales, 
round(sum(payment.amount)/(select sum(payment.amount) from payment),4)*100 as SalesPerc
from payment
inner join customer on payment.customer_id = customer.customer_id
inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id
group by country.country order by TotalSales desc;

select sum(SalesPerc) from (select country.country, round(sum(payment.amount),2) as TotalSales, 
round(sum(payment.amount)/(select sum(payment.amount) from payment),4)*100 as SalesPerc
from payment
inner join customer on payment.customer_id = customer.customer_id
inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id
group by country.country order by TotalSales desc limit 10);

select case when country.country  in ('%Russian','Italy','Germany','Spain','Poland','France','Ukraine','United Kingdom','Netherlands','Austria','Belarus',
'Latvia','Yugoslavia','Switzerland','Romania','Greece','Sweden','Holy See (Vatican City State)','Czech Republic','Bulgaria','Moldova','Estonia','Liechtenstein',
'Hungary','Finland','Slovakia','Lithuania') then 'Europe'
when country.country  in ('India','China','Japan','Philippines','Taiwan','Iran','South Korea','Turkey','Indonesia','Pakistan','Saudi Arabia','Yemen','Israel',
'Thailand','Bangladesh','Malaysia','United Arab Emirates','Cambodia','Myanmar','Hong Kong','Turkmenistan','Azerbaijan','Oman','Nepal','North Korea','Brunei',
'Iraq','Kuwait','Afghanistan') then 'Asia'
when country.country  in ('United States','Mexico','Brazil','Argentina','Colombia','Venezuela','Canada','Ecuador','Peru','Chile','Dominican Republic','Paraguay',
'Puerto Rico','Bolivia') then 'Americas'
else 'Africa and others' end as Market, round(sum(payment.amount),2) as TotalSales, 
round(sum(payment.amount)/(select sum(payment.amount) from payment),4)*100 as SalesPerc
from payment
inner join customer on payment.customer_id = customer.customer_id
inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id
group by case when country.country  in ('%Russian','Italy','Germany','Spain','Poland','France','Ukraine','United Kingdom','Netherlands','Austria','Belarus',
'Latvia','Yugoslavia','Switzerland','Romania','Greece','Sweden','Holy See (Vatican City State)','Czech Republic','Bulgaria','Moldova','Estonia','Liechtenstein',
'Hungary','Finland','Slovakia','Lithuania') then 'Europe'
when country.country  in ('India','China','Japan','Philippines','Taiwan','Iran','South Korea','Turkey','Indonesia','Pakistan','Saudi Arabia','Yemen','Israel',
'Thailand','Bangladesh','Malaysia','United Arab Emirates','Cambodia','Myanmar','Hong Kong','Turkmenistan','Azerbaijan','Oman','Nepal','North Korea','Brunei',
'Iraq','Kuwait','Afghanistan') then 'Asia'
when country.country  in ('United States','Mexico','Brazil','Argentina','Colombia','Venezuela','Canada','Ecuador','Peru','Chile','Dominican Republic','Paraguay',
'Puerto Rico','Bolivia') then 'Americas'
else 'Africa and others' end  order by TotalSales desc;

----INTERNAL BUSINESS PROCESSES
--THE MOST AND LEAST RENTED DVDs
--most
select film.title, category.name as Category, language.name as Language,
count(rental.rental_id) as TotalRents, round(sum(payment.amount),2) as TotalSales from rental
inner join payment on rental.rental_id = payment.rental_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
inner join language on film.language_id = language.language_id
group by film.title order by TotalRents desc limit 10;
--least
select film.title, category.name as Category, language.name as Language,
count(rental.rental_id) as TotalRents,round(sum(payment.amount),2) as TotalSales from rental
inner join payment on rental.rental_id = payment.rental_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
inner join language on film.language_id = language.language_id
group by film.title order by TotalRents limit 10;

-- most sales by actor
select actor.first_name, actor.last_name, count(rental.rental_id) as TotalRents, round(sum(payment.amount),2) as TotalSales,
    case when sum(payment.amount) > (select avg(TotalSales) from 
                                        (select actor.first_name, actor.last_name, sum(payment.amount) as TotalSales from rental
                                        inner join payment on rental.rental_id = payment.rental_id
                                        inner join inventory on rental.inventory_id = inventory.inventory_id
                                        inner join film on inventory.film_id = film.film_id
                                        inner join film_actor on film.film_id = film_actor.film_id
                                        inner join actor on film_actor.actor_id = actor.actor_id 
                                        group by actor.first_name, actor.last_name))+500 then 'High' 
        when sum(payment.amount) < (select avg(TotalSales) from 
                                        (select actor.first_name, actor.last_name, sum(payment.amount) as TotalSales from rental
                                        inner join payment on rental.rental_id = payment.rental_id
                                        inner join inventory on rental.inventory_id = inventory.inventory_id
                                        inner join film on inventory.film_id = film.film_id
                                        inner join film_actor on film.film_id = film_actor.film_id
                                        inner join actor on film_actor.actor_id = actor.actor_id 
                                        group by actor.first_name, actor.last_name))-500 then 'Low'
        else 'Average' end as Performance from rental
inner join payment on rental.rental_id = payment.rental_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_actor on film.film_id = film_actor.film_id
inner join actor on film_actor.actor_id = actor.actor_id 
group by actor.first_name, actor.last_name order by TotalSales desc;


--table of performance
select Performance, count(performance) as Count from (select actor.first_name, actor.last_name, count(rental.rental_id) as TotalRents, round(sum(payment.amount),2) as TotalSales,
    case when sum(payment.amount) > (select avg(TotalSales) from 
                                        (select actor.first_name, actor.last_name, sum(payment.amount) as TotalSales from rental
                                        inner join payment on rental.rental_id = payment.rental_id
                                        inner join inventory on rental.inventory_id = inventory.inventory_id
                                        inner join film on inventory.film_id = film.film_id
                                        inner join film_actor on film.film_id = film_actor.film_id
                                        inner join actor on film_actor.actor_id = actor.actor_id 
                                        group by actor.first_name, actor.last_name))+500 then 'High' 
        when sum(payment.amount) < (select avg(TotalSales) from 
                                        (select actor.first_name, actor.last_name, sum(payment.amount) as TotalSales from rental
                                        inner join payment on rental.rental_id = payment.rental_id
                                        inner join inventory on rental.inventory_id = inventory.inventory_id
                                        inner join film on inventory.film_id = film.film_id
                                        inner join film_actor on film.film_id = film_actor.film_id
                                        inner join actor on film_actor.actor_id = actor.actor_id 
                                        group by actor.first_name, actor.last_name))-500 then 'Low'
        else 'Average' end as Performance from rental
inner join payment on rental.rental_id = payment.rental_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_actor on film.film_id = film_actor.film_id
inner join actor on film_actor.actor_id = actor.actor_id 
group by actor.first_name, actor.last_name order by TotalSales)
group by Performance;

-- most sales by Category
select category.name, count(rental.rental_id) as TotalRents, round(sum(payment.amount),2) as TotalSales,
    case when sum(payment.amount) > (select avg(TotalSales) from 
                                        (select category.name, sum(payment.amount) as TotalSales from rental
                                        inner join payment on rental.rental_id = payment.rental_id
                                        inner join inventory on rental.inventory_id = inventory.inventory_id
                                        inner join film on inventory.film_id = film.film_id
                                        inner join film_category on film.film_id = film_category.film_id
                                        inner join category on film_category.category_id = category.category_id
                                        group by category.name))+300 then 'High' 
        when sum(payment.amount) < (select avg(TotalSales) from 
                                        (select category.name, sum(payment.amount) as TotalSales from rental
                                        inner join payment on rental.rental_id = payment.rental_id
                                        inner join inventory on rental.inventory_id = inventory.inventory_id
                                        inner join film on inventory.film_id = film.film_id
                                        inner join film_category on film.film_id = film_category.film_id
                                        inner join category on film_category.category_id = category.category_id
                                        group by category.name))-300 then 'Low'
        else 'Average' end as Performance from rental
inner join payment on rental.rental_id = payment.rental_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
group by category.name order by TotalSales desc;

select count(distinct(film_id)) from film;

--NO SALES

select film.title, category.name as Category, language.name as Language ,
count(rental.rental_id) as rentals from film
left join inventory on film.film_id = inventory.film_id
left join rental on inventory.inventory_id = rental.inventory_id
inner join film_actor on film.film_id = film_actor.film_id
inner join actor on film_actor.actor_id = actor.actor_id
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
inner join language on film.language_id = language.language_id
group by film.title having rentals = 0 order by rentals ;

----EMPLOYEES
--
select staff.first_name, staff.last_name, staff.store_id, staff.email, country.country,  
round(sum(payment.amount),2) as TotalSales from staff
inner join address on staff.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on country.country_id = city.country_id
inner join customer on staff.store_id =customer.store_id 
inner join payment on customer.customer_id = payment.customer_id 
group by staff.staff_id;
