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

# 第18章 全文本搜索

-- 并非所有的引擎都支持本书所描述的全文本搜索，两个最常使用的引擎为MyISAM和InnoDB，前者支持全文本搜索，而后者不支持。
-- 1.性能 —— 通配符和正则表达式匹配通常要求MySQL尝试匹配表中所有行，因此，由于被搜索行数不断增加，这些搜索可能非常耗时。
-- 2.明确控制 —— 使用通配符和正则表达式匹配，很难（而且并不总是能）明确地控制匹配什么和不匹配什么。
--   例如，指定一个词必须匹配，一个词必须不匹配，而一个词仅在第一个词确实匹配的情况下才可以匹配或者才可以不匹配。
-- 3.智能化的结果 —— 虽然基于通配符和正则表达式的搜索提供了非常灵活的搜索，但它们都不能提供一种智能化的选择结果的方法。

# 在使用全文本搜索时，MySQL不需要分别查看每个行，不需要分别分析和处理每个词。
# MySQL创建指定列中各词的一个索引，搜索可以针对这些词进行。这样，MySQL可以快速有效地决定哪些词匹配
-- 1.为了进行全文本搜索，必须索引被搜索的列，而且要随着数据的改变不断地重新索引。
-- 2.在对表列进行适当设计后，MySQL会自动进行所有的索引和重新索引。

CREATE TABLE productnotes
(
    note_id     int        NOT NULL AUTO_INCREMENT,
    prod_id     char(10)   NOT NULL,
    note_date   date_time  NOT NULL,
    note_text   text       NULL,
    PRIMARY KEY(note_id),
    FULLTEXT(note_text)
)ENGINE = MyISAM;
-- 1.这些列中有一个名为note_text的列，为了进行全文本搜索，MySQL根据子句FULLTEXT(note_text)的指示对它进行索引。
-- 2.这里的FULLTEXT索引单个列，如果需要也可以指定多个列。
-- 3.在定义之后，MySQL自动维护该索引。在增加、更新或删除行时，索引随之自动更新。
-- 4.如果正在导入数据到一个新表，此时不应该启用FULLTEXT索引。
--   应该首先导入所有数据，然后再修改表，定义FULLTEXT。这样有助于更快地导入数据（而且使索引数据的总时间小于在导入每行时分别进行索引所需的总时间）。

# 在索引之后，使用两个函数Match()和Against()执行全文本搜索，其中Match()指定被搜索的列，Against()指定要使用的搜索表达式。
SELECT note_text
FROM productnotes
WHERE Match(note_text) Against('rabbit');
# WHERE note_text LIKE '%rabbit%'
-- 1.Match(note_text)指示MySQL针对指定的列进行搜索，Against('rabbit')指定词rabbit作为搜索文本。由于有两行包含词rabbit，这两个行被返回。
-- 2.传递给Match()的值必须与FULLTEXT()定义中的相同。如果指定多个列，则必须列出它们（而且次序正确）。
-- 3.全文本搜索的一个重要部分就是对结果排序。具有较高等级的行先返回（因为这些行很可能是你真正想要的行）。
--   确实包含词rabbit的两个行每行都有一个等级值，文本中词靠前的行的等级值比词靠后的行的等级值高。

# 在使用查询扩展时，MySQL对数据和索引进行两遍扫描来完成搜索：
-- 1.首先，进行一个基本的全文本搜索，找出与搜索条件匹配的所有行；
-- 2.其次，MySQL检查这些匹配行并选择所有有用的词（我们将会简要地解释MySQL如何断定什么有用，什么无用）。
-- 3.再其次，MySQL再次进行全文本搜索，这次不仅使用原来的条件，而且还使用所有有用的词。
SELECT note_text
FROM productnotes
WHERE Match(note_text) Against('anvils' WITH QUERY EXPANSION);
-- 这次返回了7行。
-- 第一行包含词anvils，因此等级最高。
-- 第二行与anvils无关，但因为它包含第一行中的两个词（customer和recommend），所以也被检索出来。
-- 第三行也包含这两个相同的词，但它们在文本中的位置更靠后且分开得更远，因此也包含这一行，但等级为第三。第三行确实也没有涉及anvils（按它们的产品名）。
-- 正如所见，查询扩展极大地增加了返回的行数，但这样做也增加了你实际上并不想要的行的数目。

# 布尔文本搜索（即使没有定义FULLTEXT索引，也可以使用它。但这是一种非常缓慢的操作（其性能将随着数据量的增加而降低））
-- 1.要匹配的词；
-- 2.要排斥的词（如果某行包含这个词，则不返回该行，即使它包含其他指定的词也是如此）；
-- 3.排列提示（指定某些词比其他词更重要，更重要的词等级更高）;
-- 4.表达式分组；
-- 5.另外一些内容。
# 为了匹配包含heavy但不包含任意以rope开始的词的行:
SELECT note_text
FROM productnotes
WHERE Match(note_text) Against('heavy' IN BOOLEAN MODE);
# WHERE Match(note_text) Against('heavy -rope*' IN BOOLEAN MODE);
-- 此全文本搜索检索包含词heavy的所有行（有两行）。其中使用了关键字IN BOOLEANMODE，但实际上没有指定布尔操作符，因此，其结果与没有指定布尔方式的结果相同。
-- 这次只返回一行。这一次仍然匹配词heavy，但-rope*明确地指示MySQL排除包含rope*（任何以rope开始的词，包括ropes）的行，这就是为什么上一个例子中的第一行被排除的原因。

# 全文本搜索的使用说明
-- 1.在索引全文本数据时，短词被忽略且从索引中排除。短词定义为那些具有3个或3个以下字符的词（如果需要，这个数目可以更改）。
-- 2.MySQL带有一个内建的非用词（stopword）列表，这些词在索引全文本数据时总是被忽略。如果需要，可以覆盖这个列表（请参阅MySQL文档以了解如何完成此工作）。
-- 3.许多词出现的频率很高，搜索它们没有用处（返回太多的结果）。因此，MySQL规定了一条50%规则，如果一个词出现在50%以上的行中，则将它作为一个非用词忽略。50%规则不用于IN BOOLEAN MODE。
-- 4.如果表中的行数少于3行，则全文本搜索不返回结果（因为每个词或者不出现，或者至少出现在50%的行中）。
-- 5.忽略词中的单引号。例如，don't索引为dont。
-- 6.不具有词分隔符（包括日语和汉语）的语言不能恰当地返回全文本搜索结果。
-- 7.如前所述，仅在MyISAM数据库引擎中支持全文本搜索。

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


