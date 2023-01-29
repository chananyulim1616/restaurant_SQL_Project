-- Table 1
DROP TABLE employee;
CREATE TABLE employee (
  id INT unique,
  name TEXT,
  position TEXT,
  salary REAL
);

-- Table 2
DROP TABLE menu;
CREATE TABLE menu(
  food_id INT unique,
  name TEXT,
  cost REAL,
  sell_price REAL
);

-- Table 3
DROP TABLE order_tx;
create TABLE order_tx(
  tx_id INT unique,
  customer_id int,
  tx_date TEXT,
  employee_id int
);

-- Table 4
DROP TABLE order_tx_item;
create TABLE order_tx_item(
  tx_item_id INT unique,
  tx_id INT ,
  food_id int,
  quantity int
);

-- Table 5
DROP TABLE customer;
create TABLE customer(
  customer_id int unique,
  customer_name text
);

-- insert data into employee
INSERT INTO employee VALUES 
	(1, 'David', 'Waiter',9000),
  (2, 'John' , 'Waiter', 9000 ),
  (3, 'Marry', 'Cashier', 13000),
  (4, 'Karen', 'Cashier', 130000),
  (5, 'Josh', 'Chef', 18000),
  (6, 'Ceb', 'Chef', 23000);

-- insert data into menu
INSERT INTO menu VALUES 
	(1, 'Salad', 22.5,45.0),
  (2, 'Beef Steak' , 450.0, 750.0 ),
  (3, 'spaghetti' , 200.0, 350.0 ),
  (4, 'French Fried', 20.0, 45.0);

-- insert data into customer
INSERT INTO customer VALUES 
	(1,'John K.'),
  (2,'Matin L.'),
  (3,'William S.'),
  (4,'Anna G.');

-- insert data into order_tx
INSERT INTO order_tx VALUES 
	(1,1,date('2023-01-16'),3),
  (2,2,date('2023-01-17'),4),
  (3,1,date('2023-01-18'),3),
  (4,3,date('2023-01-18'),3),
  (5,4,date('2023-01-19'),4),
  (6,2,date('2023-01-19'),4),
  (7,1,date('2023-01-19'),4),
  (8,3,date('2023-01-20'),3);

-- insert data into order_tx_item
INSERT INTO order_tx_item VALUES 
	(1,1,1,1),
  (2,1,3,2),
  (3,1,2,1),
  (4,2,2,1),
  (5,2,2,1),
  (6,3,1,1),
  (7,3,3,1),
  (8,4,4,1),
  (9,4,3,2),
  (10,5,3,2),
  (11,5,1,1),
  (12,5,2,2),
  (13,6,1,1),
  (14,6,4,1),
  (15,7,2,1),
  (16,8,3,2);
;

-- Search for menu items ordered in descending order
WITH sell AS(
SELECT
  a.tx_id,
  c.name,
  c.cost,
  c.sell_price,
  a.customer_id,
  b.quantity
FROM order_tx a
join order_tx_item b
ON a.tx_id = b.tx_id
JOIN menu c
ON b.food_id = c.food_id)

select name, sum(quantity) AS total_order from sell GROUP BY name
ORDER BY total_order DESC;

-- Find out how much revenue, profit, and cost each transaction has
WITH sell AS(
SELECT
  a.tx_id,
  c.name,
  c.cost,
  c.sell_price,
  a.customer_id,
  b.quantity
FROM order_tx a
join order_tx_item b
ON a.tx_id = b.tx_id
JOIN menu c
ON b.food_id = c.food_id)

SELECT
  *,
  (total_sell-total_cost) AS total_profit
  FROM (
  SELECT
    tx_id,
    sum(sell_price*quantity) AS total_sell,
    sum(cost*quantity) AS total_cost
  FROM sell 
  GROUP BY tx_id);
  
-- Find out which employee takes care of the transaction
SELECT
  b.tx_id,
  b.tx_date,
  a.name respond_by
FROM employee a
JOIN order_tx b
ON a.id = b.employee_id;

-- How much did each customer spend ?
WITH sell AS(
SELECT
  a.tx_id,
  c.name,
  c.cost,
  c.sell_price,
  a.customer_id,
  b.quantity
FROM order_tx a
join order_tx_item b
ON a.tx_id = b.tx_id
JOIN menu c
ON b.food_id = c.food_id)

SELECT 
  customer_name,
  sum(sell_price*quantity) total_buy
from sell a
join customer b
ON a.customer_id = b.customer_id
GROUP BY customer_name
ORDER BY total_buy desc;

-- Total revenue, cost, profit of each day
WITH sell AS(
SELECT
  a.tx_id,
  c.name,
  c.cost,
  c.sell_price,
  a.customer_id,
  b.quantity
FROM order_tx a
join order_tx_item b
ON a.tx_id = b.tx_id
JOIN menu c
ON b.food_id = c.food_id),
  order_sort AS (select tx_date ,count(tx_date) total_order from(select 
    *
from order_tx a
JOIN order_tx_item b
ON a.tx_id = b.tx_id
group by a.tx_id)
group by tx_date)

select a.tx_date,total_rev,total_cost,total_profit,total_order from (select 
  tx_date,
  sum(total_sell) total_rev,
  sum(total_cost) total_cost,
  sum(total_sell)-sum(total_cost) total_profit
FROM(
SELECT 
  a.tx_date,
  (b.sell_price*b.quantity) total_sell,
  b.cost*b.quantity total_cost
from order_tx a
JOIN sell b
ON a.tx_id = b.tx_id)
group by tx_date) a
join order_sort b
on a.tx_date = b.tx_date;
