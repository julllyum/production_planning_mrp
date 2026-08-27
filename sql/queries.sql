-- проверка
SELECT 
    so.sales_order_id,
    c.customer_name,
    p.product_desc,
    so.so_quantity,
    so.so_tolerance,
    so.due_date AS so_due_date,
    c.customer_priority
FROM SupplyChain.Sales_Order so
JOIN SupplyChain.Customer c ON so.customer_id = c.customer_id
JOIN SupplyChain.Product p ON so.product_id = p.product_id
ORDER BY so.sales_order_id;


-- 1. По распределению заказов по датам сдачи
SELECT 
    due_date AS Дата_сдачи,
    COUNT(*) AS Количество_заказов,
    SUM(so_quantity) AS Общий_объем_кг
FROM SupplyChain.Sales_Order
GROUP BY due_date
ORDER BY due_date;

-- 2. По видам продукции и объемам
SELECT 
    p.product_desc AS Вид_продукции,
    COUNT(so.sales_order_id) AS Количество_заказов,
    SUM(so.so_quantity) AS Общий_объем_кг
FROM SupplyChain.Sales_Order so
JOIN SupplyChain.Product p ON so.product_id = p.product_id
GROUP BY p.product_desc
ORDER BY Общий_объем_кг DESC;

-- 3. По заказчикам и объемам
SELECT 
    c.customer_name AS Заказчик,
    COUNT(so.sales_order_id) AS Количество_заказов,
    SUM(so.so_quantity) AS Общий_объем_кг
FROM SupplyChain.Sales_Order so
JOIN SupplyChain.Customer c ON so.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY Общий_объем_кг DESC;


-- MRP план
SELECT
    mp.sales_order_id AS order_id,
    r.resource_desc AS resource,
    mp.operation_no,
    mp.required_hours AS hours,
    mp.ready_date AS work_date
FROM SupplyChain.MRP_Plan mp
JOIN SupplyChain.Resource r ON mp.resource_id = r.resource_id
WHERE mp.resource_id IS NOT NULL
  AND mp.required_hours IS NOT NULL
ORDER BY mp.sales_order_id, mp.ready_date DESC;

-- MRP план по приоритетам
SELECT 
    mp.sales_order_id AS order_id,
    r.resource_desc AS resource,
    mp.operation_no,
    mp.required_hours AS hours,
    mp.ready_date AS work_date
FROM SupplyChain.MRP_Plan mp
JOIN SupplyChain.Resource r ON mp.resource_id = r.resource_id
JOIN SupplyChain.Sales_Order so ON mp.sales_order_id = so.sales_order_id
JOIN SupplyChain.Customer c ON so.customer_id = c.customer_id
WHERE mp.resource_id IS NOT NULL
  AND mp.required_hours IS NOT NULL
ORDER BY c.customer_priority, so.due_date, mp.ready_date DESC;


-- проверка на 24 часа
SELECT 
    ready_date,
    sales_order_id,
    SUM(required_hours) AS total_hours_per_day
FROM SupplyChain.MRP_Plan
GROUP BY ready_date, sales_order_id
HAVING SUM(required_hours) > 24
ORDER BY ready_date, sales_order_id;
