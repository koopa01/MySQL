# 第23章 存储过程

-- 存储过程简单来说，就是为以后的使用而保存的一条或多条MySQL语句的集合。可将其视为批文件，虽然它们的作用不仅限于批处理。

# 为什么要使用存储过程 —— 有3个主要的好处，即简单、安全、高性能。
-- 1.通过把处理封装在容易使用的单元中，简化复杂的操作
-- 2.由于不要求反复建立一系列处理步骤，这保证了数据的完整性。（防止错误）
-- 3.简化对变动的管理。如果表名、列名或业务逻辑（或别的内容）有变化，只需要更改存储过程的代码。使用它的人员甚至不需要知道这些变化。
-- 4.提高性能。因为使用存储过程比使用单独的SQL语句要快。
-- 5.存在一些只能用在单个请求中的MySQL元素和特性，存储过程可以使用它们来编写功能更强更灵活的代码

# 将SQL代码转换为存储过程前，也必须知道它的一些缺陷。
-- 1.存储过程的编写比基本SQL语句复杂
-- 2.你可能没有创建存储过程的安全访问权限。允许用户使用存储过程，但不允许他们创建存储过程。

# 执行存储过程
-- MySQL称存储过程的执行为调用，语句为CALL。CALL接受存储过程的名字以及需要传递给它的任意参数。
CALL productpricing(@pricelow
                    @pricehigh
                    @priceaverage);
-- 执行名为productpricing的存储过程，它计算并返回产品的最低、最高和平均价格。
-- 存储过程可以显示结果，也可以不显示结果

# 创建存储过程
-- 一个返回产品平均价格的存储过程。
CREATE PROCEDURE productpricing()
BEGIN
    SELECT Avg(prod_price) AS priceaverage
    FROM products;
END;
############################################
DELMITER //
CREATE PROCEDURE productpricing()
BEGIN
    SELECT Avg(prod_price) AS priceaverage
    FROM products;
END //
DELMITER ;
-- 1.此存储过程名为productpricing，用CREATE PROCEDURE productpricing()语句定义。如果存储过程接受参数，它们将在()中列举出来。
-- 2.BEGIN和END语句用来限定存储过程体，过程体本身仅是一个简单的SELECT语句
-- 3.MySQL处理这段代码时，它创建一个新的存储过程product-pricing。没有返回数据，因为这段代码并未调用存储过程，这里只是为以后使用而创建它。
-- 4.在mysql命令行实用程序中，使用；作为语句分隔符。如果命令行实用程序要解释存储过程自身内的；字符，则它们最终不会成为存储过程的成分，出现句法错误。
--   临时更改命令行实用程序的语句分隔符,DELIMITER //告诉命令行实用程序使用//作为新的语句结束分隔符，可以看到标志存储过程结束的END定义为END//而不是END;。

# 如何使用这个存储过程
CALL productpricing();
-- 执行刚创建的存储过程并显示返回的结果。存储过程实际上是一种函数。

# 删除存储过程
DROP PROCEDURE productpricing;
DROP PROCEDURE IF EXISTS
-- 请注意没有使用后面的()，只给出存储过程名。
-- 仅当存在时删除：如果指定的过程不存在，则DROP PROCEDURE将产生一个错误。当过程存在想删除它时（如果过程不存在也不产生错误）可使用DROP PROCEDURE IF EXISTS。

# 使用参数
-- productpricing只是一个简单的存储过程，它简单地显示SELECT语句的结果。一般，存储过程并不显示结果，而是把结果返回给你指定的变量。
CREATE PROCEDURE productpricing(
    OUT pl DECIMAL(8,2),
    OUT pH DECIMAL(8,2),
    OUT pa DECIMAL(8,2)
)
BEGIN
    SELECT Min(prod_price)
    INTO p1
    FROM products
    SELECT Max(prod_price)
    INTO pH
    FROM products;
    SELECT Avg(prod_price)
    INTO pa
    FROM products;
END;
-- 1.此存储过程接受3个参数：pl存储产品最低价格，ph存储产品最高价格，pa存储产品平均价格。每个参数必须具有指定的类型，这里使用十进制值。
-- 2.关键字OUT指出相应的参数用来从存储过程传出一个值（返回给调用者）。
-- 3.MySQL支持IN（传递给存储过程）、OUT（从存储过程传出，如这里所用）和INOUT（对存储过程传入和传出）类型的参数。
-- 4.存储过程的代码位于BEGIN和END语句内，它们是一系列SELECT语句，用来检索值，然后通过指定INTO关键字保存到相应的变量。
-- 5.存储过程的参数允许的数据类型与表中使用的数据类型相同。

-- **为调用此修改过的存储过程，必须指定3个变量名
CALL productpricing(@pricelow
                    @pricehigh
                    @priceaverage);
-- 它们是存储过程将保存结果的3个变量的名字。
-- **所有MySQL变量都必须以@开始。
-- 为了显示检索出的产品平均价格
SELECT @priceaverage;
-- 为了获得3个值
SELECT @pricehigh,@pricelow,@priceaverage;

-- ordertotal接受订单号并返回该订单的合计
CREATE PROCEDURE ordertotal(
    IN onumber INT,
    OUT ototal DECIMAL(8,2)
)
BEGIN
    SELECT Sum(item_price*quantity)
    FROM orderitems
    WHERE order_num = onumber
    INTO ototal;
END;
-- onumber定义为IN，因为订单号被传入存储过程。ototal定义为OUT，因为要从存储过程返回合计。
-- SELECT语句使用这两个参数，WHERE子句使用onumber选择正确的行，INTO使用ototal存储计算出来的合计。

-- 为调用这个新存储过程
CALL ordertotal(20005,@total)
-- 必须给ordertotal传递两个参数；第一个参数为订单号，第二个参数为包含计算出来的合计的变量名。

-- 为了显示此合计
SELECT @total;
-- @total已由ordertotal的CALL语句填写，SELECT显示它包含的值。

-- 为了得到另一个订单的合计显示，需要再次调用存储过程，然后重新显示变量：
CALL ordertotal(20009,@total)
SELECT @total;

# 建立智能存储过程
-- 你获得与以前一样的订单合计，但需要对合计增加营业税，不过只针对某些顾客（或许是你所在州中那些顾客）。那么，你需要做下面几件事情：
-- 1.获得合计（与以前一样）；
-- 2.把营业税有条件地添加到合计；
-- 3.返回合计（带或不带税）。

-- Name: ordertotal
-- Parameters: onumber = order number
--             taxable = 0 if not taxable, 1 if taxable
--             ototal  = order total variable
CREATE PROCEDURE ordertotal(
    IN onumber INT,
    IN taxable BOOLEAN,
    OUT ototal DECIMAL(8,2),
) COMMENT 'Obtain order total, potionally adding tax'
BEGIN
    -- Declare variable for total
    DECLARE total DECIMAL(8,2);
    -- Declare tax percentage
    DECLARE taxrate INT DEFAULT 6;

    -- Get the order total
    SELECT Sum(item_price*quantity)
    FROM orderitems
    WHERE order_num = onumber
    INTO ototal;

    -- Is this taxable?
    IF taxable THEN
        -- Yes, so add taxrate to the total
        SELECT total+(total/100*taxrate) INTO total;
    END IF;
    -- And finally, save to out variable
    SELECT total INTO ototal;
END;
-- 1.在存储过程体中，用DECLARE语句定义了两个局部变量。DECLARE要求指定变量名和数据类型，它也支持可选的默认值
-- 2.SELECT语句已经改变，因此其结果存储到total（局部变量）而不是ototal。
-- 3.IF语句检查taxable是否为真，如果为真，则用另一SELECT语句增加营业税到局部变量total。
-- 4.最后，用另一SELECT语句将total（它增加或许不增加营业税）保存到ototal。
-- 5.COMMENT值。它不是必需的，但如果给出，将在SHOWPROCEDURE STATUS的结果中显示。

CALL ordertotal(20005,0,@total)
-- CALL ordertotal(20005,1,@total)
SELECT @total

# 检查存储过程
SHOW CREATE PROCEDURE ordertotal;
SHOWPROCEDURE STATUS
SHOWPROCEDURE STATUS LIKE 'ordertotal'
-- 显示用来创建一个存储过程的CREATE语句
-- 为了获得包括何时、由谁创建等详细信息的存储过程列表 —— 列出所有存储过程