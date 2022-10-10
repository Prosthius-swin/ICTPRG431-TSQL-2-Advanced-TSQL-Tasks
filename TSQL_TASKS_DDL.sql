-- CREATE DATABASE ICTPRG431_TSQL_2_Advanced_TSQL_Tasks;
-- GO

-- USE ICTPRG431_TSQL_2_Advanced_TSQL_Tasks;
-- GO

-- IF OBJECT_ID('Sale9468') IS NOT NULL
-- DROP TABLE Sale9468;

-- IF OBJECT_ID('Product9468') IS NOT NULL
-- DROP TABLE PRODUCT9468;

-- IF OBJECT_ID('Customer9468') IS NOT NULL
-- DROP TABLE CUSTOMER9468;

-- IF OBJECT_ID('Location9468') IS NOT NULL
-- DROP TABLE LOCATION9468;

-- GO

-- CREATE TABLE CUSTOMER9468 (
-- CUSTID	INT
-- , CUSTNAME	NVARCHAR(100)
-- , Sales_YTD	MONEY
-- , STATUS	NVARCHAR(7)
-- , PRIMARY KEY	(CUSTID) 
-- );


-- CREATE TABLE PRODUCT9468 (
-- PRODID	INT
-- , PRODNAME	NVARCHAR(100)
-- , SELLING_PRICE	MONEY
-- , Sales_YTD	MONEY
-- , PRIMARY KEY	(PRODID)
-- );

-- CREATE TABLE Sale9468 (
-- SaleID	BIGINT
-- , CUSTID	INT
-- , PRODID	INT
-- , QTY	INT
-- , PRICE	MONEY
-- , SaleDATE	DATE
-- , PRIMARY KEY 	(SaleID)
-- , FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER9468
-- , FOREIGN KEY 	(PRODID) REFERENCES PRODUCT9468
-- );

-- CREATE TABLE LOCATION9468 (
--   LOCID	NVARCHAR(5)
-- , MINQTY	INTEGER
-- , MAXQTY	INTEGER
-- , PRIMARY KEY 	(LOCID)
-- , CONSTRAINT CHECK_LOCID_LENGTH CHECK (LEN(LOCID) = 5)
-- , CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999)
-- , CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999)
-- , CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
-- );

-- IF OBJECT_ID('Sale_SEQ') IS NOT NULL
-- DROP SEQUENCE Sale_SEQ;
-- CREATE SEQUENCE Sale_SEQ;

-- GO

-- 1
DROP PROCEDURE IF EXISTS ADD_CUSTOMER;
GO
CREATE PROCEDURE ADD_CUSTOMER @pcustid INT, @pcustname NVARCHAR(100) AS
BEGIN
  BEGIN TRY
    IF @pcustid < 1 OR @pcustid > 499
      THROW 50020, 'Customer ID outside range', 1;

    INSERT INTO CUSTOMER9468 (CUSTID, CUSTNAME, Sales_YTD, STATUS)
    VALUES (@pcustid, @pcustname, 0, 'OK');
  END TRY
  BEGIN CATCH
    IF ERROR_NUMBER() = 2627
      THROW 50010, 'Customer ID already exists', 1;
    ELSE IF ERROR_NUMBER() = 50020
      THROW 50020, 'Customer ID outside range', 1;
    ELSE
      DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1;
  END CATCH
END

GO

EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'John Smith';
GO
EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'Jane Smith';
GO
EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'John Doe';
GO
EXEC ADD_CUSTOMER @pcustid = '', @pcustname = 'John Doe';
GO


-- 2
DROP PROCEDURE IF EXISTS DELETE_ALL_CUSTOMERS;
GO
CREATE PROCEDURE DELETE_ALL_CUSTOMERS AS
BEGIN
  BEGIN TRY
    DELETE FROM CUSTOMER9468;
    RETURN @@ROWCOUNT;
  END TRY
  BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
    THROW 50000, @ERRORMESSAGE, 1;
  END CATCH
END
GO

EXEC DELETE_ALL_CUSTOMERS;
GO



-- 3
DROP PROCEDURE IF EXISTS ADD_PRODUCT;
GO

CREATE PROCEDURE ADD_PRODUCT @pprodid INT, @pprodname NVARCHAR(100), @pprice MONEY AS
BEGIN
  BEGIN TRY
    IF @pprodid < 1000 OR @pprodid > 2500
      THROW 50040, 'Product ID outside range', 1;
    ELSE IF @pprice < 0 OR @pprice > 999.99
      THROW 50050, 'Price outside range', 1;
    ELSE
      INSERT INTO PRODUCT9468 (PRODID, PRODNAME, SELLING_PRICE, Sales_YTD)
      VALUES (@pprodid, @pprodname, @pprice, 0);
  END TRY
  BEGIN CATCH
    IF ERROR_NUMBER() = 2627
      THROW 50030, 'Duplicate Product ID', 1;
    ELSE IF ERROR_NUMBER() = 50040
      THROW 50040, 'Product ID out of range', 1;
    ELSE IF ERROR_NUMBER() = 50050
      THROW 50050, 'Price out of range', 1;
    ELSE
      DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1;
  END CATCH
END
GO

EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = 'Product 1', @pprice = 10.00;
GO
EXEC ADD_PRODUCT @pprodid = 1000, @pprodname = 'Product 2', @pprice = 20.00;
GO
EXEC ADD_PRODUCT @pprodid = 999, @pprodname = 'Product 3', @pprice = 30.00;
GO
EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'Product 4', @pprice = 1000.00;
GO
EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'Product 5', @pprice = 10.00;
GO



-- 4
DROP PROCEDURE IF EXISTS UPD_CUST_SALESYTD;
GO
CREATE PROCEDURE UPD_CUST_SALESYTD @pcustid INT, @pamt MONEY AS
BEGIN
  BEGIN TRY
    IF @pamt < -999.99 OR @pamt > 999.99
      THROW 50080, 'Amount out of range', 1;
    ELSE
      UPDATE CUSTOMER9468
      SET Sales_YTD = Sales_YTD + @pamt
      WHERE CUSTID = @pcustid
        IF @@ROWCOUNT = 0
          THROW 50070, 'Customer ID not found', 1;
  END TRY
  BEGIN CATCH
    IF ERROR_NUMBER() = 50070
      THROW 50070, 'Customer ID not found', 1;
    ELSE IF ERROR_NUMBER() = 50080
      THROW 50080, 'Amount out of range', 1;
    ELSE
      DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1;
  END CATCH
END
GO

EXEC UPD_CUST_SALESYTD @pcustid = 0, @pamt = 100.00;
GO
EXEC UPD_CUST_SALESYTD @pcustid = 1, @pamt = -1000.00;
GO
EXEC UPD_CUST_SALESYTD @pcustid = 1, @pamt = 100.00;
GO

-- 5
DROP PROCEDURE IF EXISTS UPD_PROD_SALESYTD;
GO
CREATE PROCEDURE UPD_PROD_SALESYTD @pprodid INT, @pamt MONEY AS
BEGIN
  BEGIN TRY
    IF @pamt < -999.99 OR @pamt > 999.99
      THROW 50110, 'Amount out of range', 1;
    ELSE
      UPDATE PRODUCT9468
      SET Sales_YTD = Sales_YTD + @pamt
      WHERE PRODID = @pprodid
        IF @@ROWCOUNT = 0
          THROW 50100, 'Product ID not found', 1;
  END TRY
  BEGIN CATCH
    IF ERROR_NUMBER() = 50100
      THROW 50100, 'Product ID not found', 1;
    ELSE IF ERROR_NUMBER() = 50110
      THROW 50110, 'Amount out of range', 1;
    ELSE
      DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1;
  END CATCH
END
GO

EXEC UPD_PROD_SALESYTD @pprodid = 999999999, @pamt = 100.00;
GO
EXEC UPD_PROD_SALESYTD @pprodid = 1, @pamt = -1000.00;
GO
EXEC UPD_PROD_SALESYTD @pprodid = 1000, @pamt = 100.00;
GO

-- 6
DROP PROCEDURE IF EXISTS SUM_CUSTOMER_SALESYTD;
GO
CREATE PROCEDURE SUM_CUSTOMER_SALESYTD AS
BEGIN
  BEGIN TRY
    SELECT SUM(Sales_YTD) AS Total_Sales
    FROM CUSTOMER9468;
  END TRY
  BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
    THROW 50000, @ERRORMESSAGE, 1;
  END CATCH
END

EXEC SUM_CUSTOMER_SALESYTD;
GO



-- 7
DROP PROCEDURE IF EXISTS GET_ALL_PRODUCTS;
GO
CREATE PROCEDURE GET_ALL_PRODUCTS @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
  BEGIN TRY
    SET @POUTCUR = CURSOR FOR
    SELECT *
    FROM PRODUCT9468;

    OPEN @POUTCUR;
  END TRY
  BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
    THROW 50000, @ERRORMESSAGE, 1;
  END CATCH
END
GO

BEGIN
DECLARE @outProd AS CURSOR, @prodID INT, @prodName NVARCHAR(100), @sellingPrice MONEY, @salesYTD MONEY;
EXEC GET_ALL_PRODUCTS @POUTCUR = @outProd OUTPUT;

FETCH NEXT FROM @outProd INTO @prodID, @prodName, @sellingPrice, @salesYTD;

WHILE @@FETCH_STATUS = 0
  BEGIN
    PRINT CONCAT ('Product ID: ', @prodID, ', Product Name: ', @prodName, ', Selling Price: ', @sellingPrice, ', Sales YTD: ', @salesYTD);
    FETCH NEXT FROM @outProd INTO @prodID, @prodName, @sellingPrice, @salesYTD;
  END

CLOSE @outProd;
DEALLOCATE @outProd;
END
GO


-- 8
DROP PROCEDURE IF EXISTS ADD_SALE;
GO
CREATE PROCEDURE ADD_SALE @pcustid INT, @pprodid INT, @pqty INT, @pdate DATE AS
BEGIN
  BEGIN TRY
    DECLARE @pCustStatus NVARCHAR(7)

    IF @pqty < 1 OR @pqty > 999
      THROW 50230, 'Sale quantity outside valid range', 1;
    -- ELSE IF 

    INSERT INTO SALE9468 (SALEID, CUSTID, PRODID, QTY, SALEDATE)
    VALUES (NEXT VALUE FOR Sale_SEQ, @pcustid, @pprodid, @pqty, @pdate);
  END TRY
  BEGIN CATCH
    IF ERROR_NUMBER() = 50230
      THROW 50230, 'Sale quantity outside valid range', 1;
    ELSE
      DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
      THROW 50000, @ERRORMESSAGE, 1;
  END CATCH
END
    
EXEC ADD_SALE @pcustid = 1, @pprodid = 1, @pqty = 1, @pdate = '2019-01-01';

SELECT * FROM sys.sequences WHERE name = 'SALE_SEQ';
