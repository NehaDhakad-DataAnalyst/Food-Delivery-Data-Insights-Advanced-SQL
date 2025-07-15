
--Q1 Find Top 3 Outlet by cuisine type without using limit and top function

with cte as (
select Cuisine,Restaurant_id,count(*) as no_of_orders
from orders
group by Cuisine,Restaurant_id)
select * from (
select *,
ROW_NUMBER() over(partition by cuisine order by no_of_orders desc) as rn
from cte ) a
where rn<=3


-------------------------------------------------------------------------------------
-- Q2 Find the daily new Customer count from the launch date  (every day how many new customers are we acquiring)

with cte as(
select Customer_code, cast(MIN(placed_at) as date) as first_order_date
from orders
group by Customer_code)

select first_order_date,count(*) as no_of_new_customers
from cte
group by first_order_date
order by first_order_date;

------------------------------------------------------------------------------------

--Q3 Count of all the users who were acquired in Jan 2025 (First order should be in Jan 2025) 
--and only placed one order in Jan
--and did not place any other order

select Customer_code,COUNT(*) as no_of_orders
from orders
where YEAR(placed_at)=2025 
      and MONTH(placed_at)=1
	  and Customer_code not in (select distinct Customer_code 
	                            from  orders where not (YEAR(placed_at)=2025 
                                                   and MONTH(placed_at)=1))

group by Customer_code
having count(*)=1

-------------------------------------------------------------------------


--Q4 List all the customers with no order in the last 7 days but were acquired one month ago with 
--their first order on promo.
with cte as(
select Customer_code, MIN(placed_at) as first_order_date,
MAX(placed_at) as latest_order_date
from orders
group by Customer_code)

select cte.*, orders.Promo_code_Name
from cte
inner join orders on cte.Customer_code=orders.Customer_code 
and cte.first_order_date=orders.Placed_at
where latest_order_date < DATEADD(day,-7,getdate())
and first_order_date < DATEADD(Month,-1,getdate())
and Promo_code_Name is not null

-------------------------------------------------------------------------

--Q5 Growth team is planning to create a trigger that will target customers after thier every third
-- order with the personalized cummunication and they have asked you to create a query for this

with cte as(
select * ,
ROW_NUMBER() over(partition by customer_code order by placed_at) as order_number
from orders
)

select * 
from cte
where order_number%3=0 and cast(Placed_at as date) = cast(GETDATE() as date)

--------------------------------------------------------------------------------

--Q6 List Customers who placed more than 1 order and all their orders on promo code only

select Customer_code, count(*) as no_of_orders, count(promo_code_name) as no_of_promocode
from orders
--where Promo_code_Name is not null
group by Customer_code
having count(*)>1 and count(promo_code_name)=COUNT(*)

-----------------------------------------------------------------------

--Q7 What percentage of customers were organically acquired in Jan 2025. 
--(placed their first order without promo code)

with cte as(
select * ,
ROW_NUMBER() over(partition by customer_code order by placed_at) as rn
from orders)

select count(case when rn=1 and promo_code_name is null then customer_code end)*100.0/ count(*)
from cte


