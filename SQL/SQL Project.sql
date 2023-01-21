## Using Database Orders
use orders;

/*
	1. Write a query to display the product details (product_class_code, product_id, product_desc, product_price) 
		as per the following criteria and sort them descending order of category:

	i) If the category is 2050, increase the price by 2000
	ii) If the category is 2051, increase the price by 500
	iii) If the category is 2052, increase the price by 600 
 */

select  product_id
       ,product_desc
       ,product_class_code
       ,case when product_class_code = 2050 then product_price + 2000
			 when product_class_code = 2051 then product_price + 500
             when product_class_code = 2052 then product_price + 600
	    else product_price end AS product_price
from product
order by product_class_code desc;

/*
	2. Write a query to display (product_class_desc, product_id, product_desc, product_quantity_avail ) 
		and Show inventory status of products as below as per their available quantity:
	
    a. For Electronics and Computer categories, if available quantity is <= 10, show 'Low stock', 11 <= qty <= 30, show 'In stock', >= 31, show 'Enough stock'
	b. For Stationery and Clothes categories, if qty <= 20, show 'Low stock', 21 <= qty <= 80, show 'In stock', >=81, show 'Enough stock'
	c. Rest of the categories, if qty <= 15 – 'Low Stock', 16 <= qty <= 50 – 'In Stock', >= 51 – 'Enough stock'
	For all categories, if available quantity is 0, show 'Out of stock'.
*/

select pro.product_id
	   ,pro.product_desc
       ,pclass.product_class_desc
       ,pro.product_quantity_avail
       ,case when pclass.product_class_desc in ('Electronics', 'Computer') then
			 case when pro.product_quantity_avail = 0 then 'Out of Stock'
                  when pro.product_quantity_avail between 1 and 10 then 'Low Stock'
				  when pro.product_quantity_avail between 11 and 30 then 'In Stock'
                  when pro.product_quantity_avail >= 31 then 'Enough Stock'
		     end
	         when pclass.product_class_desc in ('Stationery', 'Clothes') then
			 case when pro.product_quantity_avail = 0 then 'Out of Stock'
                  when pro.product_quantity_avail between 1 and 20 then 'Low Stock'
				  when pro.product_quantity_avail between 21 and 80 then 'In Stock'
                  when pro.product_quantity_avail >= 81 then 'Enough Stock'
		     end
             else
             case when pro.product_quantity_avail = 0 then 'Out of Stock'
				  when pro.product_quantity_avail between 1 and 15 then 'Low Stock'
				  when pro.product_quantity_avail between 16 and 50 then 'In Stock'
                  when pro.product_quantity_avail >= 51 then 'Enough Stock'
		     end
		end inventory_status
from product as pro
left join product_class as pclass on pclass.product_class_code = pro.product_class_code
order by pro.product_quantity_avail desc;

/*
	3. Write a query to Show the count of cities in all countries other than USA & MALAYSIA, 
		with more than 1 city, in the descending order of CITIES.
*/

select country
	   ,count(distinct city) count_of_cities
from address
where country not in ('USA', 'Malaysia')
group by country
having count(distinct city) > 1
order by count(distinct city) desc;

/*
	4. Write a query to display the customer_id, customer full name, city, pincode, and order details 
       (order id, product class desc, product desc, subtotal(product_quantity * product_price)) 
       for orders shipped to cities whose pin codes do not have any 0s in them. Sort the output on customer name, order date and subtotal.
*/

select cust.customer_id
	   ,concat(cust.customer_fname, ' ', customer_lname) as customer_full_name
	   ,ad.city
       ,ad.pincode
       ,ohead.order_id
       ,pclass.product_class_desc
       ,pro.product_desc
       ,(oitem.product_quantity * pro.product_price) as subtotal
from online_customer as cust
left join address as ad on ad.address_id = cust.address_id
left join order_header as ohead on ohead.customer_id = cust.customer_id
left join order_items as oitem on oitem.order_id = ohead.order_id
left join product as pro on pro.product_id = oitem.product_id
left join product_class as pclass on pclass.product_class_code = pro.product_class_code

where ohead.order_status = 'Shipped'
	  and ad.pincode not like '%0%'
order by (cust.customer_fname + customer_lname), ohead.order_date, (oitem.product_quantity * pro.product_price);

/*
	5. Write a Query to display product id,product description,totalquantity(sum(product quantity) for a
		given item whose product id is 201 and which item has been bought along with it maximum no. of times. 
        Display only one record which has the maximum value for total quantity in this scenario.
*/

select oitems.product_id
	   ,pro.product_desc
	   ,sum(oitems.product_quantity) as totalquantity
from order_items as oitems
left join product as pro on pro.product_id = oitems.product_id
where oitems.order_id in (select order_id from order_items where product_id = 201)
group by oitems.product_id
		,pro.product_desc
order by sum(oitems.product_quantity) desc
limit 1;

/*
	6. Write a query to display the customer_id,customer name, email and order details
		(order id, product desc,product qty, subtotal(product_quantity * product_price)) 
		for all customers even if they have not ordered any item.
*/

select cust.customer_id
	  ,concat(cust.customer_fname, ' ', customer_lname) as customer_name
      ,cust.customer_email
	  ,ohead.order_id
      ,pro.product_desc
      ,oitems.product_quantity
      ,(oitems.product_quantity * pro.product_price) subtotal
from online_customer as cust
left join order_header as ohead on ohead.customer_id = cust.customer_id
left join order_items as oitems on oitems.order_id = ohead.order_id
left join product as pro on pro.product_id = oitems.product_id;

/*
	7. Write a query to display carton id ,(len*width*height) as carton_vol and identify the optimum carton 
		(carton with the least volume whose volume is greater than the total volume of all items
        (len * width * height * product_quantity)) for a given order whose order id is 10006, 
        Assume all items of an order are packed into one single carton (box).
        
        (1 ROW)[NOTE :CARTON TABLE]
*/

select carton_id, (len * width * height) as carton_vol
from carton
where 
(len * width * height) >= (select sum(pro.len * pro.width * pro.height * ohead.product_quantity) as volume_all_items
						 from order_items as ohead
						 left join product as pro on pro.product_id = ohead.product_id
						 where ohead.order_id = 10006)
order by (len * width * height) asc
limit 1;

/*
	8. Write a query to display details (customer id,customer fullname,order id,product quantity)
		of customers who bought more than ten (i.e. total order qty) products with credit card or net
		banking as the mode of payment per shipped order.
*/

select cust.customer_id
	  ,concat(cust.customer_fname, ' ', customer_lname) as customer_full_name
      ,ohead.order_id
      ,sum(oitems.product_quantity) total_order_quantity
from online_customer as cust
left join order_header as ohead on ohead.customer_id = cust.customer_id
left join order_items as oitems on oitems.order_id = ohead.order_id
where ohead.payment_mode in ('Net Banking', 'Credit Card')
	 and ohead.order_status = 'Shipped'
group by cust.customer_id
		,concat(cust.customer_fname, ' ', customer_lname)
		,ohead.order_id
having sum(oitems.product_quantity)>10
order by sum(oitems.product_quantity) desc;

/*
	9.Write a query to display the order_id,customer_id and customer fullname starting with “A” along
		with (product quantity) as total quantity of products shipped for order ids > 10030.
*/

select ohead.order_id
	   ,cust.customer_id
	   ,concat(cust.customer_fname, ' ', customer_lname) as customer_full_name
       ,sum(oitems.product_quantity) total_quantity
from online_customer as cust
left join order_header as ohead on ohead.customer_id = cust.customer_id
left join order_items as oitems on oitems.order_id = ohead.order_id
where cust.customer_fname like 'A%'
	and ohead.order_id > 10030
    and ohead.order_status = 'Shipped'
group by ohead.order_id
	    ,cust.customer_id
	    ,concat(cust.customer_fname, ' ', customer_lname)
order by sum(oitems.product_quantity) desc;

/*
	10. Write a query to display product class description, totalquantity(sum(product_quantity),
		Total value (product_quantity * product price) and show which class of products have been shipped
		highest(Quantity) to countries outside India other than USA? Also show the total value of those items.
*/

select  pclass.product_class_desc
       ,sum(oitems.product_quantity) total_quantity
	   ,sum(oitems.product_quantity * pro.product_price) as total_value
from online_customer as cust
left join address as ad on ad.address_id = cust.address_id
left join order_header as ohead on ohead.customer_id = cust.customer_id
left join order_items as oitems on oitems.order_id = ohead.order_id
left join product as pro on pro.product_id = oitems.product_id
left join product_class as pclass on pclass.product_class_code = pro.product_class_code
where ad.country not in ('India', 'USA')
	  and ohead.order_status = 'Shipped'
group by pclass.product_class_desc
order by sum(product_quantity) desc
limit 1;