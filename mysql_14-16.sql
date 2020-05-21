# 14
# 需要列出订购物品TNT2的所有客户
-- (1) 检索包含物品TNT2的所有订单的编号。
-- (2) 检索具有前一步骤列出的订单编号的所有客户的ID。
-- (3) 检索前一步骤返回的所有客户ID的客户信息。
SELECT cust_name, cust_contact
FROM customers
WHERE cust_id IN (SELECT cust_id
				  FROM orders
				  WHERE order_num IN (SELECT order_num
									  FROM orderitems
									  WHERE prod_id = 'TNT2'));
-- 等同于
SELECT cust_name, cust_contact
FROM customers, orders, orderitems
-- FROM customers AS c, orders AS o, orderitems AS oi
WHERE customer.cust_id = orders.cust_id
-- WHERE x.cust_id = o.cust_id
	AND orderitems.order_num = orders.order_num
    -- AND oi.order_num = o.order_num
    AND prod_id = 'TNT2';
# 在实际使用时由于性能的限制，不能嵌套太多的子查询。
# 表别名可用于其他部分，只在查询执行中使用，不返回到客户机

# customers表中每个客户的订单总数
SELECT 
    cust_name,
    cust_state,
    (SELECT COUNT(*)
        FROM orders
        WHERE orders.cust_id = customers.cust_id) AS orders
FROM customers
ORDER BY cust_name;
# 子查询对检索出的每个客户执行一次。在此例子中，该子查询执行了5次，因为检索出了5个客户。

# 15 内部联结（等值连结）
-- 内部联结 FROM ... INNER JOIN ... ON ...
-- 联结多个表
# 外键为某个表中的一列，它包含另一个表的主键值，定义了两个表之间的关系。
-- 1.信息不重复，不浪费时间空间
-- 2.如果信息变动，课只更新单个记录，相关表中数据不用动
-- 3.数据是一致的，处理数据更简单
# 能够适应不断增加的工作量而不失败。设计良好的数据库或应用程序称之为可伸缩性好（scale well）。
SELECT vend_name, prod_name, prod_price
# FROM venders INNER JOIN prosducts ON vendors.vend_id = products.vend_id
FROM vendors, products
WHERE vendors.vend_id = products.vend_id
ORDER BY vend_name, prod_name;
# 当FROM两个表时，基本上等于使用连结数据，在引用的列可能出现二义性时，必须使用完全限定列名。
# 没有WHERE子句，第一个表中的每个行将与第二个表中的每个行配对，而不管它们逻辑上是否可以配在一起。
# ANSI SQL规范首选INNER JOIN语法。尽管使用WHERE子句定义联结的确比较简单，但是使用明确的联结语法能够确保不会忘记联结条件，有时候这样做也能影响性能。

# 联结多个表
SELECT prod_name, vend_name, prod_price, quantity
FROM orderitems, products, vendors
WHERE products.vend_id = vendors.vend_id
	AND orderitems.prod_id = products.prod_id
    AND order_num = 20005;
-- 此例子显示编号为20005的订单中的物品。订单物品存储在orderitems表中。每个产品按其产品ID存储，它引用products表中的产品。
-- 这些产品通过供应商ID联结到vendors表中相应的供应商，供应商ID存储在每个产品的记录中。
-- 这里的FROM子句列出了3个表，而WHERE子句定义了这两个联结条件，而第三个联结条件用来过滤出订单20005中的物品。
# MySQL在运行时关联指定的每个表以处理联结。这种处理可能是非常耗费资源的，因此应该仔细，不要联结不必要的表。联结的表越多，性能下降越厉害。

# 为执行任一给定的SQL操作，一般存在不止一种方法。很少有绝对正确或绝对错误的方法。性能可能会受操作类型、表中数据量、是否存在索引或键以及其他一些条件的影响。

# 16 自联结、自然联结和外部联结
# 自联结
# 发现某物品（其ID为DTNTR）存在问题，因此想知道生产该物品的供应商生产的其他物品是否也存在这些问题。
 SELECT prod_id, prod_name
 FROM products
 WHERE vend_id = (SELECT vend_id
				  FROM products
                  WHERE prod_id = 'DTNTR');
 # 等同于                 
SELECT p1.prod_id, p1.prod_name
FROM products AS p1, products AS p2
WHERE p1.vend_id = p2.vend_id
  AND p2.prod_id = 'DTNTR'
# 自联结通常作为外部语句用来替代从相同表中检索数据时使用的子查询语句。虽然最终的结果是相同的，但有时候处理联结远比处理子查询快得多。

# 自然联结
# 自然联结是这样一种联结，其中你只能选择那些唯一的列。这一般是通过对表使用通配符（SELECT *），对所有其他表的列使用明确的子集来完成的。
SELECT c.*, o.order_num, o.order_date, oi.prod_id, oi.quantity, oi.item_price
FROM customers AS c, orders AS o, orderitems AS oi
WHERE c.cust_id = o.cust_id
  AND oi.order_num = o.order_num
  AND prod_id = 'FB'
# 通配符只对第一个表使用。所有其他列明确列出，所以没有重复的列被检索出来。

# 外部联结
# 外部联结语法类似。为了检索所有客户，包括那些没有订单的客户
SELECT customers.cust_id, orders.order_num
# FROM customers INNER JOIN orders ON customers.cust_id = orders.cust_id;
FROM customers LEFT OUTER JOIN orders ON customers.cust_id = orders.cust_id;
# 与内部联结关联两个表中的行不同的是，外部联结还包括没有关联行的行。
# 在使用OUTER JOIN语法时，必须使用RIGHT或LEFT关键字指定包括其所有行的表（RIGHT指出的是OUTER JOIN右边的表，而LEFT指出的是OUTER JOIN左边的表）。
# 上面的例子使用LEFT OUTER JOIN从FROM子句的左边表（customers表）中选择所有行。为了从右边的表中选择所有行，应该使用RIGHT OUTER JOIN

# 如果要检索所有客户及每个客户所下的订单数
SELECT customers.cust_id, customers.cust_name, COUNT(orders.order_num) AS num_of_ord
FROM customers INNER JOIN orders ON customers.cust_id = orders.cust_id
-- FROM customers LEFT OUTER JOIN orders ON customers.cust_id = orders.cust_id 用做外部连结来包含所有客户，甚至包含那些没有任何下订单的客户。结果显示也包含了客户Mouse House，它有0个订单。
GROUP BY customers.cust_id;
# 此SELECT语句使用INNER JOIN将customers和orders表互相关联。GROUP BY子句按客户分组数据，因此，函数调用COUNT(orders.order_num)对每个客户的订单计数，将它作为num_ord返回。




