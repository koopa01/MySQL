# 第20章 更新和删除数据

-- 使用UPDATE语句。可采用两种方式使用UPDATE：
-- 1.更新表中特定行；
-- 2.更新表中所有行。
# 不要省略WHERE子句 在使用UPDATE时一定要注意细心。因为稍不注意，就会更新表中所有行。
UPDATE customers
UPDATE IGNORE customers
SET cust_name = 'The Fudds',
    cust_email = 'elmer@fudd.com'
--  cust_email = NULL
WHERE cust_id = 10005;
-- 1.要更新的表名
-- 2.将新值赋给被更新的列
-- 3.where告诉MySQL更新哪一行。如果没有WHERE子句，MySQL将会用这个电子邮件地址更新customers表中所有行
-- 4.如果用UPDATE语句更新多行，并且在更新这些行中的一行或多行时出现一个错误，则整个UPDATE操作被取消（错误发生前更新的所有行被恢复到它们原来的值）。

# 删除数据
-- 两种方式使用DELETE：
-- 1.从表中删除特定的行；
-- 2.从表中删除所有行。
# 不要省略WHERE子句 在使用DELETE时一定要注意细心。因为稍不注意，就会错误地删除表中所有行。
DELETE FROM customers
WHERE cust_id = 10006;
-- 1.DELETE FROM要求指定从中删除数据的表名。
-- 2.WHERE子句过滤要删除的行。
-- 3.如果省略WHERE子句，它将删除表中每个客户。
# 删除表的内容而不是表 DELETE不需要列名或通配符。DELETE删除整行而不是删除列。
# 更快的删除 如果想从表中删除所有行，不要使用DELETE。可使用TRUNCATE TABLE语句，速度更快（删除原来的表并重新创建一个表，而不是逐行删除表中的数据）。

# 更新和删除的指导原则
-- UPDATE和DELETE语句全都具有WHERE子句。如果省略了WHERE子句，则UPDATE或DELETE将被应用到表中所有的行。
-- 1.除非确实打算更新和删除每一行，否则绝对不要使用不带WHERE子句的UPDATE或DELETE语句。
-- 2.保证每个表都有主键，尽可能像WHERE子句那样使用它（可以指定各主键、多个值或值的范围）。
-- 3.在对UPDATE或DELETE语句使用WHERE子句前，应该先用SELECT进行测试，保证它过滤的是正确的记录，以防编写的WHERE子句不正确。
-- 4.使用强制实施引用完整性的数据库，这样MySQL将不允许删除具有与其他表相关联的数据的行。
# 小心使用 MySQL没有撤销（undo）按钮。

# 第21章 创建和操纵表

#为利用CREATE TABLE创建表，必须给出下列信息：
-- 1.新表的名字，在关键字CREATE TABLE之后给出；
-- 2.表列的名字和定义，用逗号分隔。
CREATE TABLE customers
(   --括号内为表中所有列的定义
    cust_id      int        NOT NULL AUTO_INCREMENT,
    cust_name    char(50)   NOT NULL,
    cust_address char(50)   NULL,
    cust_city    char(50)   NULL,
    cust_state   char(5)    NULL,
    cust_zip     char(10)   NULL,
    cust_country char(50)   NULL,
    cust_contact char(50)   NULL,
    cust_email   char(255)  NULL,
    PRIMARY KEY (cust_id)
)ENGINE = InnoDB;
-- 处理现有的表 在创建新表时，指定的表名必须不存在，否则将出错。
-- 如果要防止意外覆盖已有的表，SQL要求首先手工删除该表，然后再重建它，而不是简单地用创建表语句覆盖它。

# 使用NULL值
CREATE TABLE orders
(
    order_num    int        NOT NULL AUTO_INCREMENT,
    order_date   datetime   NOT NULL,
    cust_id      int        NOT NULL,
    PRIMARY KEY (order_num)
)ENGINE = InnoDB;
-- 所有3个列都需要值，因此每个列的定义都含有关键字NOT NULL。这将会阻止插入没有值的列。
-- 如果试图插入没有值的列，将返回错误，且插入失败。

# 主键
-- 如果主键使用单个列，则它的值必须唯一。如果使用多个列，则这些列的组合值必须唯一。
CREATE TABLE orderitems
(
    order_num   int          NOT NULL,
    order_item  int          NOT NULL,
    prod_id     char(10)     NOT NULL,
    quantity    int          NOT NULL  DEFAULT 1, -- 在未给出数量的情况下使用数量1。
    item_price  decimal(8,2) NOT NULL,
    PRIMARY KEY (order_num, order_item)
)ENGINE = InnoDB
-- 每个订单有多项物品，但每个订单任何时候都只有1个第一项物品，1个第二项物品，如此等等。
-- 因此，订单号（order_num列）和订单物品（order_item列）的组合是唯一的，从而适合作为主键
-- 主键中只能使用不允许NULL值的列。允许NULL值的列不能作为唯一标识。
-- 如果在插入行时没有给出值，MySQL允许指定此时使用的默认值。

# 使用AUTO_INCREMENT
-- 1.AUTO_INCREMENT告诉MySQL，本列每当增加一行时自动增量。
-- 2.每次执行一个INSERT操作时，MySQL自动对该列增量（从而才有这个关键字AUTO_INCREMENT），给该列赋予下一个可用的值。
-- 3.这样给每个行分配一个唯一的cust_id，从而可以用作主键值。
-- 4.每个表只允许一个AUTO_INCREMENT列，而且它必须被索引（如，通过使它成为主键）。
-- 5.覆盖AUTO_INCREMENT 如果一个列被指定为AUTO_INCRE-MENT，则它需要使用特殊的值吗？
--   可以在INSERT语句中指定一个值，只要它是唯一的（至今尚未使用过）即可，该值将被用来替代自动生成的值。后续的增量将开始使用该手工插入的值。
-- 6.确定AUTO_INCREMENT值 让MySQL生成（通过自动增量）主键的一个缺点是你不知道这些值都是谁。

# 不允许函数 与大多数DBMS不一样，MySQL不允许使用函数作为默认值，它只支持常量。

# 引擎类型
-- 1.MySQL有一个具体管理和处理数据的内部引擎。在你使用CREATE TABLE语句时，该引擎具体创建表
--   而在你使用SELECT语句或进行其他数据库处理时，该引擎在内部处理你的请求。多数时候，此引擎都隐藏在DBMS内，不需要过多关注它。
-- 2.但MySQL与其他DBMS不一样，它具有多种引擎。
--   它打包多个引擎，这些引擎都隐藏在MySQL服务器内，全都能执行CREATE TABLE和SELECT等命令。
-- 3.如果省略ENGINE=语句，则使用默认引擎（很可能是MyISAM），多数SQL语句都会默认使用它。
# 几个需要知道的引擎：
-- 1.InnoDB是一个可靠的事务处理引擎，它不支持全文本搜索；
-- 2.MEMORY在功能等同于MyISAM，但由于数据存储在内存（不是磁盘）中，速度很快（特别适合于临时表）；
-- 3.MyISAM是一个性能极高的引擎，它支持全文本搜索，但不支持事务处理。
-- 注意：外键不能跨引擎 混用引擎类型有一个大缺陷。外键用于强制实施引用完整性，使用一个引擎的表不能引用具有使用不同引擎的表的外键。

# 更新表
-- 使用ALTER TABLE更改表结构，必须给出下面的信息：
-- 1.在ALTER TABLE之后给出要更改的表名（该表必须存在，否则将出错）；
-- 2.所做更改的列表。
ALTER TABLE vendors
ADD vend_phone CHAR(20);    -- 给vendors表增加一个名为vend_phone的列，必须明确其数据类型。
# DROP COLUMN vend_phone;   -- 删除刚刚添加的列
# ALTER TABLE的一种常见用途是定义外键。
ALTER TABLE orderitems
ADD CONSTRAINT fk_orderitems_orders
FOREIGN KEY (order_num)
REFERENCES orders (order_num);

ALTER TABLE orderitems
ADD CONSTRAINT fk_orderitems_products
FOREIGN KEY (prod_id)
REFERENCES products (prod_id);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (cust_id)
REFERENCES customers (cust_id);

ALTER TABLE products
ADD CONSTRAINT fk_products_vendors
FOREIGN KEY (vend_id)
REFERENCES vendors (vend_id);
-- 由于要更改4个不同的表，使用了4条ALTER TABLE语句。
-- 复杂的表结构更改一般需要手动删除过程，它涉及以下步骤：
-- 1.用新的列布局创建一个新表；
-- 2.使用INSERT SELECT语句，从旧表复制数据到新表。如果有必要，可使用转换函数和计算字段；
-- 3.检验包含所需数据的新表；
-- 4.重命名旧表（如果确定，可以删除它）；
-- 5.用旧表原来的名字重命名新表；
-- 6.根据需要，重新创建触发器、存储过程、索引和外键。
-- 使用ALTER TABLE要极为小心，应该在进行改动前做一个完整的备份（模式和数据的备份）。

# 删除表
DROP TABLE customers2;
-- 删除表没有确认，也不能撤销，执行这条语句将永久删除该表。

# 重命名表
RENAME TABLE customers2 TO customers3;
RENAME TABLE backup_customers TO customers,
             backup_vendors TO vendors,
             backup_products TO products;

# 第22章 使用视图
-- MySQL 5之后添加了对视图的支持。
-- 视图是虚拟的表。与包含数据的表不一样，视图只包含使用时动态检索数据的查询。
SELECT cust_name, cust_contact
FROM customers, orders, orderitems
WHERE customer.cust_id = orders.cust_id
    AND orderitems.order_num = orders.order_num
    AND prod_id = 'TNT2';
-- 现在，假如可以把整个查询包装成一个名为productcustomers的虚拟表，则可以如下轻松地检索出相同的数据：
SELECT cust_name, cust_contact
FROM productcustomers
WHERE prod_id = 'TNT2'
-- productcustomers是一个视图，作为视图，它不包含表中应该有的任何列或数据，它包含的是一个SQL查询

# 用视图重新格式化检索出的数据
CREATE VIEW vendorlocations AS
SELECT Concat(Rtrim(vend_name), '(', Rtrim(vend_country), ')')
       AS vend_title
FROM vendors
ORDER BY vend_name;
-- 假如经常需要这个格式的结果。不必在每次需要时执行联结，创建一个视图，每次需要时使用它即可。
-- 如果需要检索出以创建所有邮件标签的数据
SELECT *
FROM vendorlocations;

# 为什么使用视图
-- 1.重用SQL语句。
-- 2.简化复杂的SQL操作。在编写查询后，可以方便地重用它而不必知道它的基本查询细节。
-- 3.使用表的组成部分而不是整个表。
-- 4.保护数据。可以给用户授予表的特定部分的访问权限而不是整个表的访问权限。
-- 5.更改数据格式和表示。视图可返回与底层表的表示和格式不同的数据。
-- 视图仅仅是用来查看存储在别处的数据的一种设施，其本身不包含数据，因此它们返回的数据是从其他表中检索出来的。
-- 在添加或更改这些表中的数据时，视图将返回改变过的数据。
-- 所以每次使用视图时，都必须处理查询执行时所需的任一个检索。如果用多个联结和过滤创建了复杂的视图或者嵌套了视图，可能会发现性能下降得很厉害。



