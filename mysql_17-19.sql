# 第17章 组合查询

-- 假如需要价格小于等于5的所有物品的一个列表，而且还想包括供应商1001和1002生产的所有物品
SELECT vend_id, prod_id, prod_price
FROM products
WHERE vend_id IN (1001,1002)
UNION
SELECT vend_id, prod_id, prod_price
FROM products
WHERE prod_price <= 5
ORDER BY vend_id, prod_price;

-- UNION从查询结果集中自动去除了重复的行，如果想返回所有匹配行，可使用UNION ALL
-- 这条语句由前面的两条SELECT语句组成，语句中用UNION关键字分隔。UNION指示MySQL执行两条SELECT语句，并把输出组合成单个查询结果集。
-- 对于更复杂的过滤条件，或者从多个表（而不是单个表）中检索数据的情形，使用UNION可能会使处理更简单。

-- 1.UNION必须由两条或两条以上的SELECT语句组成，如果组合4条SELECT语句，将要使用3个UNION关键字.
-- 2.UNION中的每个查询必须包含相同的列、表达式或聚集函数
-- 3.列数据类型必须兼容：类型不必完全相同，但必须是DBMS可以隐含地转换的类型（例如，不同的数值类型或不同的日期类型）。
-- 4.在用UNION组合查询时，只能使用一条ORDER BY子句，它必须出现在最后一条SELECT语句之后。

# 第19章 插入数据

INSERT INTO customers
VALUES(NULL,
    'Pep E. LaPew',
    '100 Main Street',
    'Los Angleles'
    'CA',
    '90046',
    'USA',
    NULL,
    NULL,
):
-- 虽然这种语法很简单，但并不安全，应该尽量避免使用。
-- 上面的SQL语句高度依赖于表中列的定义次序，并且还依赖于其次序容易获得的信息。
-- 即使可得到这种次序信息，也不能保证下一次表结构变动后各个列保持完全相同的次序。
-- 因此，编写依赖于特定列次序的SQL语句是很不安全的。如果这样做，有时难免会出问题。虽

INSERT INTO customers(cust_name,
    cust_address,
    cust_city,
    cust_state,
    cust_zip,
    cust_country,
    cust_contact,
    cust_email)
VALUES('Pep E. LaPew',
    '100 Main Street',
    'Los Angleles'
    'CA',
    '90046',
    'USA',
    NULL,
    NULL
),
    ('M. Martian',
        '42 Galaxy Way',
        'New York',
        'NY',
        '11213'
        'USA',
        NULL,
        NULL
);
-- 在表名后的括号里明确地给出了列名。在插入行时，MySQL将用VALUES列表中的相应值填入列表中的对应项。
-- 优点是，即使表的结构改变，此INSERT语句仍然能正确工作。cust_id的NULL值是不必要的，cust_id列并没有出现在列表中，所以不需要任何值。
-- 1.总是使用列的列表
-- 2.仔细地给出值，必须给出VALUES的正确数目。
-- 3.省略列:可以在INSERT操作中省略某些列。1.该列定义为允许NULL值 2.在表定义中给出默认值。这表示如果不给出值，将使用默认值。
-- 4.提高整体性能：INSERT操作可能很耗时，如果数据检索是最重要的（通常是这样），则你可以通过在INSERT和INTO之间添加关键字LOW_PRIORITY，指示MySQL降低INSERT语句的优先级

# 插入检索出的数据
INSERT INTO customers(cust_id,
    cust_contact,
    cust_email,
    cust_name,
    cust_address,
    cust_city,
    cust_state,
    cust_zip,
    cust_country)
SELECT cust_id,
    cust_contact,
    cust_email,
    cust_name,
    cust_address, 
    cust_city,
    cust_state,
    cust_zip,
    cust_country
FROM custnew;
-- 使用INSERT SELECT从custnew中将所有数据导入customers。
-- SELECT语句从custnew检索出要插入的值，而不是列出它们。
-- 如果这个表确实含有数据，则所有数据将被插入到customers。
-- 这个例子导入了cust_id（假设你能够确保cust_id的值不重复）。你也可以简单地省略这列（从INSERT和SELECT中），这样MySQL就会生成新值。


