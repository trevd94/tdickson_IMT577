/******************************
Course: IMT 577
Instructor: Sean Pettersen
Date: 02/27/2022
*****************************************/
CREATE VIEW CHANNEL
AS 
SELECT
    DIMCHANNELID,
    CHANNELID,
    CHANNELCATEGORYID,
    CHANNELNAME,
    CHANNELCATEGORY
FROM
    DIM_CHANNEL;
    
CREATE VIEW CUSTOMER
AS
SELECT
    DIMCUSTOMERID,
    DIMLOCATIONID,
    CUSTOMERID,
    CUSTOMERFULLNAME,
    CUSTOMERFIRSTNAME,
    CUSTOMERLASTNAME,
    CUSTOMERGENDER
FROM
    DIM_CUSTOMER;
    
CREATE VIEW DATE
AS
SELECT
DATE_PKEY,
DATE,
FULL_DATE_DESC,
DAY_NUM_IN_WEEK,
DAY_NUM_IN_MONTH,
DAY_NUM_IN_YEAR,
DAY_NAME,
DAY_ABBREV,
WEEKDAY_IND,
US_HOLIDAY_IND,
_HOLIDAY_IND,
MONTH_END_IND,
WEEK_BEGIN_DATE_NKEY,
WEEK_BEGIN_DATE,
WEEK_END_DATE_NKEY,
WEEK_END_DATE,
WEEK_NUM_IN_YEAR,
MONTH_NAME,
MONTH_ABBREV,
MONTH_NUM_IN_YEAR,
YEARMONTH,
QUARTER,
YEARQUARTER,
YEAR,
FISCAL_WEEK_NUM,
FISCAL_MONTH_NUM,
FISCAL_YEARMONTH,
FISCAL_HALFYEAR,
FISCAL_YEAR,
SQL_TIMESTAMP,
CURRENT_ROW_IND,
EFFECTIVE_DATE,
EXPIRATION_DATE
FROM
DIM_DATE;

CREATE VIEW LOCATION
AS
SELECT 
    DIMLOCATIONID,
    ADDRESS,
    CITY,
    POSTALCODE,
    STATE_PROVINCE,
    COUNTRY
FROM
    DIM_LOCATION;
    
CREATE VIEW PRODUCT
AS
SELECT 
    DIMPRODUCTID,
    PRODUCTID,
    PRODUCTTYPEID,
    PRODUCTCATEGORYID,
    PRODUCTNAME,
    PRODUCTTYPE,
    PRODUCTCATEGORY,
    PRODUCTRETAILPRICE,
    PRODUCTWHOLESALEPRICE,
    PRODUCTCOST,
    PRODUCTRETAILPROFIT,
    PRODUCTWHOLESALEUNITPROFIT,
    PRODUCTPROFITMARGINUNITPERCENT
FROM
    DIM_PRODUCT;
    
CREATE VIEW RESELLER
AS
SELECT
    DIMRESELLERID,
    DIMLOCATIONID,
    RESELLERID,
    RESELLERNAME,
    CONTACTNAME,
    PHONENUMBER,
    EMAIL
FROM
    DIM_RESELLER;
    
CREATE VIEW STORE
AS
SELECT
    DIMSTOREID,
    DIMLOCATIONID,
    SOURCESTOREID,
    STORENAME,
    STORENUMBER,
    STOREMANAGER
FROM
    DIM_STORE;
    
CREATE VIEW PRODUCTSALESTARGET
AS
SELECT
    DIMPRODUCTID,
    DIMTARGETDATEID,
    PRODUCTTARGETSALESQUANTITY
FROM
    FACT_PRODUCTSALESTARGET;
    
CREATE VIEW SALESACTUAL
AS
SELECT
    DIMPRODUCTID,
    DIMSTOREID,
    DIMRESELLERID,
    DIMCUSTOMERID,
    DIMCHANNELID,
    DIMSALEDATEID,
    DIMLOCATIONID,
    SALESHEADERID,
    SALESDETAILID,
    SALEAMOUNT,
    SALEQUANTITY,
    SALEUNITPRICE,
    SALEEXTENDEDCOST,
    SALETOTALPROFIT
FROM
    FACT_SALESACTUAL;
    
CREATE VIEW SRCSALESTARGET
AS
SELECT
    DIMSTOREID,
    DIMRESELLERID,
    DIMCHANNELID,
    DIMTARGETDATEID,
    SALESTARGETAMOUNT
FROM
    FACT_SRCSALESTARGET;


CREATE OR REPLACE VIEW SalesActual_VS_SalesTarget
AS
select 
s.storename as store_name, 
d.year, 
src.salestargetamount as target, 
sum(sa.saleamount) as total
from
fact_salesactual sa
INNER JOIN
dim_date d
on sa.dimsaledateid = d.date_pkey
INNER JOIN
dim_store s
ON 
sa.dimstoreid = s.dimstoreid
INNER join fact_srcsalestarget src
on src.dimstoreid = s.storenumber and src.dimtargetdateid = sa.dimsaledateid
where sa.dimstoreid in (select dimstoreid from dim_store where storename in ('5', '8'))
group by s.storename, d.year, src.salestargetamount;



CREATE OR REPLACE VIEW product_sales_by_weekday
AS
select 
p.productname product,
d.day_name day_of_week,
s.storename store,
sum(sa.saleamount) total_sales,
sum(sa.salequantity) total_quantity,
sum(sa.saletotalprofit) total_profit,
avg(sa.saleamount) average_sales,
avg(sa.salequantity) average_quantity,
avg(sa.saletotalprofit) average_profit
from 
fact_salesactual sa
INNER JOIN
dim_product p
ON sa.dimproductid = p.dimproductid
INNER JOIN 
dim_date d
on sa.dimsaledateid = d.date_pkey
INNER JOIN
dim_store s
ON sa.dimstoreid = s.dimstoreid
WHERE s.storename in ('5', '8')
group by p.productname, d.day_name, s.storename
order by 1,2,3;

CREATE OR REPLACE VIEW product_sales_by_producttype
AS
select
s.storename, 
d.year,
p.producttype,
sum(sa.saleamount) total_sales,
sum(sa.salequantity) total_quantity,
sum(sa.saletotalprofit) total_profit
from 
fact_salesactual sa
INNER JOIN
dim_product p
ON sa.dimproductid = p.dimproductid
INNER JOIN 
dim_date d
on sa.dimsaledateid = d.date_pkey
INNER JOIN
dim_store s
ON sa.dimstoreid = s.dimstoreid
WHERE s.storename in ('5', '8')
and p.producttype in ('Men''s Casual', 'Women''s Casual')
group by s.storename, d.year, p.producttype
order by 1,2,3

CREATE OR REPLACE VIEW sales_by_state
AS
select
s.storename,
l.state_province,
sum(sa.saleamount) total_sales,
sum(sa.salequantity) total_quantity,
sum(sa.saletotalprofit) total_profit
from
fact_salesactual sa
INNER JOIN
dim_store s
ON sa.dimstoreid = s.dimstoreid
INNER JOIN
dim_location l
ON s.dimlocationid = l.dimlocationid
where s.storename != 'Unknown'
group by s.storename, l.state_province
order by 2,1;





