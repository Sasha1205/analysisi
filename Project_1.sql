--The best selling brands (Savelii)
SELECT brand_name
FROM (
   SELECT b.brand_name, SUM(oi.quantity) AS total_quantity
   FROM brands b
   INNER JOIN order_items oi ON b.brand_id = brand_id
   GROUP BY b.brand_name
) AS subquery
ORDER BY total_quantity DESC
LIMIT 3;

--The best selling categories (Savelii)
SELECT category_name
FROM categories
WHERE category_id IN (
 SELECT category_id
 FROM categories
 INNER JOIN order_items ON categories.category_id = category_id
 GROUP BY category_id
 ORDER BY SUM(quantity) DESC
 LIMIT 3);

--Manager who sold the most, in terms of money (Savelii)
SELECT s.staff_id, s.first_name, s.last_name, SUM(oi.quantity * oi.list_price) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN staff s ON o.staff_id = s.staff_id
GROUP BY s.staff_id
ORDER BY total_sales DESC
LIMIT 1;

-- Shop with the greatest number of sales (Ilya)
select s.store_name, sum(oi.quantity) as quan
from stores s
join orders o using (store_id)
join order_items oi using (order_id)
group by s.store_name
order by quan desc;

-- In what dates orders are mostly done (Ilya)
select o.order_date, count(o.order_date) as times, dense_rank()over(order by -count(o.order_date)) as top
from orders o
group by o.order_date;

-- Discount is bigger (Ilya)
select p.model_year, round(avg(oi.discount), 4)
from order_items oi
join products p using (product_id)
group by p.model_year
order by avg(oi.discount) desc;

-- The best-selling model (Alexandra)
SELECT subquery.product_name, subquery.model_year, subquery.total_quantity
FROM (
   SELECT p.product_name, p.model_year, SUM(s.quantity) AS total_quantity
   FROM products p
   INNER JOIN stock s ON p.product_id = s.product_id
   GROUP BY p.product_name, p.model_year
) AS subquery
ORDER BY total_quantity DESC
LIMIT 10;

-- The customers who bought the most different products (Alexandra)
SELECT c.customer_id, c.first_name, c.last_name, c.city, c.state, COUNT(DISTINCT oi.product_id) AS distinct_products_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE c.customer_id IN (
   SELECT o.customer_id
   FROM orders o
   JOIN order_items oi ON o.order_id = oi.order_id
   GROUP BY o.customer_id
   HAVING COUNT(DISTINCT oi.product_id) >= 10
)
group by  c.customer_id
order by distinct_products_count desc;

-- How the delivery works (Alexandra)
SELECT order_id, customer_id, staff_id, store_id, required_date, shipped_date,
      AGE(shipped_date, required_date) AS difference_days_delivery,
      shipped_date - required_date AS numerical_difference_delivery,
      CASE
          WHEN shipped_date - required_date > (SELECT ROUND(AVG(shipped_date - required_date)) FROM orders WHERE shipped_date IS NOT NULL) THEN 'Problem with delivery'
          WHEN shipped_date - required_date = (SELECT ROUND(AVG(shipped_date - required_date)) FROM orders WHERE shipped_date IS NOT NULL) THEN 'Good delivery'
          ELSE 'Below time delivery'
      END AS grade_of_delivery,
      COUNT(CASE
              WHEN shipped_date - required_date > (SELECT ROUND(AVG(shipped_date - required_date)) FROM orders WHERE shipped_date IS NOT NULL) THEN order_id
              ELSE NULL
            END) OVER() AS problem_with_delivery_count,
      COUNT(CASE
              WHEN shipped_date - required_date = (SELECT ROUND(AVG(shipped_date - required_date)) FROM orders WHERE shipped_date IS NOT NULL) THEN order_id
              ELSE NULL
            END) OVER() AS good_delivery_count,
      COUNT(CASE
              WHEN shipped_date - required_date < (SELECT ROUND(AVG(shipped_date - required_date)) FROM orders WHERE shipped_date IS NOT NULL) THEN order_id
              ELSE NULL
            END) OVER() AS below_delivery_count
FROM orders
WHERE shipped_date IS NOT NULL
ORDER BY numerical_difference_delivery DESC;