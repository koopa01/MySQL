[SQL必知必会 第四版](https://weread.qq.com/web/reader/95232130715c01b39521460k8f132430178f14e45fce0f7)
#1.数据库基础
---
## 数据库
数据库软件应称为数据库管理系统（DBMS）
将数据库想象为一个文件柜。这个文件柜是一个存放数据的物理位置，不管数据是什么，也不管数据是如何组织的。

## 表
你往文件柜里放资料时，是在文件柜中创建文件，然后将相关的资料放入特定的文件中。
在数据库领域中，这种文件称为表。表是一种结构化的文件，可用来存储某种特定类型的数据。表可以保存顾客清单、产品目录，或者其他信息清单。
数据库中的每个表都有一个名字来标识自己。这个名字是唯一的，即数据库中没有其他表具有相同的名字。

## 列
正确地将数据分解为多个列极为重要。例如，城市、州、邮政编码应该总是彼此独立的列。
数据库中每个列都有相应的数据类型。数据类型（datatype）定义了列可以存储哪些数据种类。
例如，如果列中存储的是数字（或许是订单中的物品数），则相应的数据类型应该为数值类型。
如果列中存储的是日期、文本、注释、金额等，则应该规定好恰当的数据类型。

## 行
表中的数据是按行存储的，所保存的每个记录存储在自己的行内。如果将表想象为网格，网格中垂直的列为表列，水平行为表行。

## 主键
表中每一行都应该有一列（或几列）可以唯一标识自己。
一列（或一组列），其值能够唯一标识表中每一行。

**注意：**记录一旦插入到表中，主键最好不要再修改，因为主键是用来唯一定位记录的，修改了主键，会造成一系列的影响。
主键不要带有业务含义，而应该使用BIGINT自增或者GUID类型。主键也不应该允许NULL。
可以使用多个列作为联合主键，但联合主键并不常用。
可以使用自增类型：BIGINT NOT NULL AUTO_INCREMENT类型

    全局唯一GUID类型：类似8f55d96b-8acc-4636-8cb8-76bf8abc2f57。
	GUID算法通过网卡MAC地址、时间戳和随机数保证任意计算机在任意时间生成的字符串都是不同的，大部分编程语言都内置了GUID算法，可以自己预算出主键。

## 外键
外键并不是通过列名实现的，而是通过定义外键约束实现的：
一个classes的记录可以对应多个students表的记录。
```
ALTER TABLE students
ADD CONSTRAINT fk_class_id
FOREIGN KEY (class_id)
REFERENCES classes (id);
```

# 2.什么是SQL
---
Structured Query Language（结构化查询语言）

## SELECT语句
检索单个列：

>SELECT 想选择什么
FROM 从什么地方选择;

比如：
```
SELECT prod_id,prod_names,prod_price -- 行内注释
From Products;
```

## 单行注释
/*    多行注释    */

多条SQL语句必须以分号（;）分隔。SQL语句不区分大小写，在处理SQL语句时，其中所有空格都被忽略。
SQL语句一般返回原始的、无格式的数据。数据的格式化是表示问题，而不是检索问题。

## 检索所有列
```
SELECT *
From Products;
```

除非你确实需要表中的每一列，否则最好别使用＊通配符。检索不需要的列通常会降低检索和应用程序的性能。

## 检索不同的值
DISTINCT关键字
```
SELECT DISTINCT vend_id
From Products;
```

SELECT DISTINCT vend_id告诉DBMS只返回不同（具有唯一性）的vend_id行
如果使用DISTINCT关键字，它必须直接放在列名的前面
DISTINCT关键字作用于所有的列，不仅仅是跟在其后的那一列。

## 限制结果
在SQL Server和Access中使用SELECT时，可以使用TOP关键字来限制最多返回多少行，SELECT TOP 5，只检索前5行数据。
```
SELECT TOP 5 prod_names
From Products;
```

如果使用的是DB2
```
SELECT prod_names
From Products
FATCH FIRST 5 ROWS ONLY;
```

如果使用Oracle，需要基于ROWNUM（行计数器）来计算行
```
SELECT prod_names
From Products
WHERE ROWNUM <= 5;
```

如果使用MySQL、MariaDB、PostgreSQL或者SQLite，需要使用LIMIT子句
```
SELECT prod_names
From Products
LIMIT 5 OFFSET 5;
```

LIMIT 5 OFFSET 5指示MySQL等DBMS返回从第5行起的5行数据。第一个数字是检索的行数，第二个数字是指从哪儿开始。
**注意：**第一个被检索的行是第0行，而不是第1行。因此，LIMIT 1 OFFSET 1会检索第2行，而不是第1行。

MySQL、MariaDB和SQLite支持简化版的LIMIT 4 OFFSET 3语句，即LIMIT 3,4。

# 3.排序检索数据
---
## 排序数据
在指定一条ORDER BY子句时，应该保证它是SELECT语句中最后一条子句。
```
SELECT prod_id,prod_name,prod_price
From Products
ORDER BY prod_price,prod_names;
```

先按price排序，之后按names排序。仅在多个行具有相同的prod_price值时才对产品按prod_name进行排序。如果prod_price列中所有的值都是唯一的，则不会按prod_name排序。

## 按列位置排序
**尽量不采用这种方式**

```
SELECT prod_id,prod_name,prod_price
From Products
ORDER BY 2,3;
```

## 指定排序方向
为了进行降序排序，必须指定DESC关键字。
DESC是DESCENDING的缩写，这两个关键字都可以使用。与DESC相对的是ASC（或ASCENDING）

```
SELECT prod_id,prod_name,prod_price
From Products
ORDER BY prod_price DESC,prod_names;
```

DESC关键字只应用到直接位于其前面的列名。因此，prod_price列以降序排序，而prod_name列（在每个价格内）仍然按标准的升序排序。

# 4.过滤数据
---
## 使用WHERE子句
数据库表一般包含大量的数据，很少需要检索表中的所有行。通常只会根据特定操作或报告的需要提取表数据的子集。
只检索所需数据需要指定搜索条件（search criteria），搜索条件也称为过滤条件（filter condition）
在SELECT语句中，数据根据WHERE子句中指定的搜索条件进行过滤。WHERE子句在表名（FROM子句）之后给出。
```
SELECT prod_id,prod_name,prod_price
From Products
WHERE prod_price = 3.49;
```
从products表中检索两个列，只返回prod_price值为3.49的行
应该让ORDER BY位于WHERE之后。

## WHERE子句操作符

操作符 | 说明 | 操作符 | 说明
- | - | - | -
= | 等于 | > | 大于
<> | 不等于 | >= | 大于等于
!= | 不等于 | !> | 不大于
< | 小于 | BETWEEN | 在指定的两值之间
<= | 小于等于 | IS NULL | 为NULL值
!< | 不小于 | |

* 并非所有DBMS都支持这些操作符。

## 不匹配检查
```
SELECT vend_id,prod_id,prod_name,prod_price
From Products
WHERE vend_id <>'DLL01'
ORDER BY prod_price,prod_names;
```

* **提示：**何时使用引号如果仔细观察上述WHERE子句中的条件，会看到有的值括在单引号内，而有的值未括起来。
单引号用来限定字符串。如果将值与字符串类型的列进行比较，就需要限定引号。用来与数值列进行比较的值不用引号。

## 范围值检查
```
SELECT prod_name,prod_price
From Products
WHERE prod_price BETWEEN 5 AND 10;
```
在使用BETWEEN时，必须指定两个值——所需范围的低端值和高端值。这两个值必须用AND关键字分隔。
BETWEEN匹配范围中所有的值，包括指定的开始值和结束值。

## 空值检查
```
SELECT cust_name
From Customers
WHERE cust_name IS NULL;
```

**注意：NULL和非匹配**
通过过滤选择不包含指定值的所有行时，你可能希望返回含NULL值的行。
但是这做不到。因为未知（unknown）有特殊的含义，数据库不知道它们是否匹配，所以在进行匹配过滤或非匹配过滤时，不会返回这些结果。
过滤数据时，一定要验证被过滤列中含NULL的行确实出现在返回的数据中。

**注意：**在同时使用ORDER BY和WHERE子句时，应该让ORDER BY位于WHERE之后。

# 5.组合WHERE子句
SQL允许给出多个WHERE子句。这些子句有两种使用方式，即以AND子句或OR子句的方式使用。

## AND、OR、BETWEEN操作符
要通过不止一个列进行过滤，可以使用AND操作符给WHERE子句附加条件。
```
SELECT vend_id,prod_names,prod_price
From Products
WHERE vend_id = 'DLL01' AND prod_price <= 4;
```

BETWEEN匹配范围中所有的值，包括指定的开始值和结束值。

## IN/NOT IN操作符
此SELECT语句检索供应商1002和1003制造的所有产品。IN操作符后跟由逗号分隔的合法值清单，整个清单必须括在圆括号中。
```
SELECT prod_name,prod_price
From Products
WHERE vend_id IN (1002,1003)
ORDER BY prod_name;
```
IN操作符完成与OR相同的功能, IN操作符一般比OR操作符清单执行更快。
IN的最大优点是可以包含其他SELECT语句，使得能够更动态地建立WHERE子句。第14章将对此进行详细介绍。

## 指定排序方向
这只是默认的排序顺序，还可以使用ORDER BY子句以降序（从Z到A）顺序排序。为了进行降序排序，必须指定DESC关键字。
DESC关键字只应用到直接位于其前面的列名。
想在多个列上进行降序排序，必须对每个列指定DESC关键字。

```
SELECT prod_name,prod_price,prod_id
From Products
ORDER BY prod_price DESC, prod_name
LIMIT 1,1
# LIMIT 1 OFFSET 1;
```

使用ORDER BY和LIMIT的组合，能够找出一个列中最高或最低的值。下面的例子演示如何找出最昂贵物品的值：
在给出ORDER BY子句时，应该保证它位于FROM子句之后。如果使用LIMIT，它必须位于ORDER BY之后。使用子句的次序不对将产生错误消息。

# 6.用通配符进行过滤
## LIKE和通配符（% _ ）
通配符（wildcard）：用来匹配值的一部分的特殊字符。
搜索模式（search pattern）：由字面值、通配符或两者组合构成的搜索条件。
前面介绍的所有操作符都是过滤中使用的值都是已知的。例如，怎样搜索产品名中包含文本anvil的所有产品？
为在搜索子句中使用通配符，必须使用LIKE操作符。(用LIKE也一定要用通配符)
```
SELECT prod_name,prod_price
From Products
WHERE prod_name LIKE 'jet%'
# WHERE prod_name LIKE ’%anvil%’ 表示匹配任何位置包含文本anvil的值，而不论它之前或之后出现什么字符。
```
此例子使用了搜索模式’jet%'。在执行这条子句时，将检索任意以jet起头的词。 %告诉MySQL接受jet之后的任意字符，不管它有多少字符。
**注意**：根据MySQL的配置方式，搜索可以是区分大小写的。如果区分大小写，'jet%’与JetPack 1000将不匹配。
**注意 NULL**：虽然似乎%通配符可以匹配任何东西，但有一个例外，即NULL。即使是WHERE prod_name LIKE '%’也不能匹配用值NULL作为产品名的行。
下划线（_）通配符：下划线的用途与%一样，但下划线只匹配单个字符而不是多个字符。

MySQL的通配符很有用。但这种功能是有代价的：通配符搜索的处理一般要比前面讨论的其他搜索所花时间更长。
如没必要，不要用通配符，更不要用在搜索模式的开始处。

# 7.用正则表达式进行搜索
正则表达式的作用是匹配文本，将一个模式（正则表达式）与一个文本串进行比较。
## 基本字符匹配

```
SELECT prod_name,prod_price
From Products
WHERE prod_name REGEXP '.000'
# WHERE prod_name REGEXP '1000|2000'  |表示OR
ORDER BY prod_name;
```
．是正则表达式语言中一个特殊的字符。它表示匹配任意一个字符.

```
SELECT prod_name,prod_price
From Products
WHERE prod_name REGEXP '[123] ton' # 也可以'[1-3] ton'
ORDER BY prod_name;
```
[]是另一种形式的OR语句，正则表达式中尽量不要用OR，因为容易引起歧义，比如'1|2|3 ton'
\\为转义字符，比如\\. ,\\- ,\\f ,\\\

## 定位符
元字符 | 说明
- | - 
^ | 文本的开始
$ | 文本的结尾
[[:<:]] | 词的开始
[[:>:]] | 词的结尾

例如，如果你想找出以一个数（包括以小数点开始的数）开始的所有产品
```
SELECT prod_name
From Products
WHERE prod_name REGEXP '^[0-9\\.]'
ORDER BY prod_name;
```

## 简单的正则表达式测试
可以在不使用数据库表的情况下用SELECT来测试正则表达式。REGEXP检查总是返回0（没有匹配）或1（匹配）。
SELECT 'hello' REGEXP '[0-9]' # 返回0

# 8.创建计算字段
字段（field）基本上与列（column）的意思相同
需要返回字段相加、计算、改变格式、改变大小写等需要直接从数据库中检索出转换、计算或格式化过的数据时，使用计算字段。
可使用Concat()函数来拼接两个列。

```
SELECT Concat(Rtrim(vend_name), '(' , Rtrim(vend_county) , ')') AS vend_title # vend_title为别名
From Vendors
ORDER BY vend_name;
```
即格式化输出。
RTrim()（去掉串右边的空格），LTrim()（去掉串左边的空格），Trim()（去掉串左右两边的空格）。

```
SELECT prod_id, quantity, item_price,
       quantity*item_prices AS expanded_price
From Orderitems
WHERE order_num = 20005;
```

# 9.使用数据处理函数
函数降低可读性从而降低可移植性，要注释。
customers表中有一个顾客Coyote Inc.，其联系名为Y.Lee。但如果这是输入错误，此联系名实际应该是Y.Lie，怎么办？
```
SELECT cust_name, cust_contact
FROM customers
WHERE Soundex(cust_contact) = Soundex('Y.Lie') # 它匹配所有发音类似于Y.Lie的联系名
```
[更多函数](https://weread.qq.com/web/reader/929321f0715c01b5929bd3fkc7432af0210c74d97b01b1c)

```
SELECT CONCAT(last_name,'_',first_name) AS 姓名 FROM employees;

SELECT CONCAT(UPPER(last_name),LOWER(first_name)) AS 姓名 FROM employees;

SELECT SUBSTR('我是koopa'，3，5) AS out_put #从第3个字符开始截取后面5个字符

#将姓名中首字符大写，其他字符小写，用_拼接，显示出来
SELECT CONCAT(SUBSTR(UPPER(last_name), 1, 1), SUBSTR(LOWER(last_name, 2),'_', LOWER(first_name)) FROM empolyees;

SELECT INSTR('我是koopa','koopa') AS out_put;      #返回字串第一次出现的索引，如果没有，返回0

SELECT LENGTH(TRIM('    KOOPA    ')) AS out_put;         #返回9，每个汉字大小为3字节，返回结果为去掉空格的大小

SELECT TRIM('a' FROM 'aaaaaaa我是aaaaaaaakoopaaaaaaaa');       #去掉前后的a，中间a的保留

SELECT LPAD('koopa', 10, '*') AS out_put;        #左边用*填充直到输出10个字符（用左填充指定字符至指定长度）

SELECT REPLACE('koopa and morty', 'koopa', 'rick') AS out_put;      #替换
```



















