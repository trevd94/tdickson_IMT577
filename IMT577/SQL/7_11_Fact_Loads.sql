/******************************
Course: IMT 577
Instructor: Sean Pettersen
Date: 02/16/2022
*****************************************/
CREATE OR REPLACE TABLE Fact_SalesActual(
    DimProductID INT CONSTRAINT FK_FactSalesDimProduct FOREIGN KEY
        REFERENCES DIM_PRODUCT (DimProductID) NOT NULL
  ,DimStore INT CONSTRAINT FK_FactSalesDimStore FOREIGN KEY
        REFERENCES DIM_Store (DimStoreID) NOT NULL
  ,DimResellerID INT CONSTRAINT FK_FactSalesDimReseller FOREIGN KEY
        REFERENCES DIM_Reseller (DimResellerID) NOT NULL
  ,DimCustomerID INT CONSTRAINT FK_FactSalesDimCustomer FOREIGN KEY
        REFERENCES DIM_Customer (DimCustomerID) NOT NULL
  ,DimChannelID INT CONSTRAINT FK_FactSalesDimChannel FOREIGN KEY
        REFERENCES DIM_Channel (DimChannelID) NOT NULL
  ,DimSaleDateID NUMBER(9) CONSTRAINT FK_FactSalesDimDate FOREIGN KEY
        REFERENCES DIM_Date (Date_PKey) NOT NULL
  ,DimLocationID INT CONSTRAINT FK_FactSalesDimLocation FOREIGN KEY
        REFERENCES DIM_Location (DimLocationID) NOT NULL
  ,SalesHeaderID INT NOT NULL
  ,SalesDetailID INT NOT NULL
  ,SaleAmount FLOAT NOT NULL
  ,SaleQuantity INT NOT NULL
  ,SaleUnitPrice FLOAT NOT NULL
  ,SaleExtendedCost FLOAT NOT NULL
  ,SaleTotalProfit FLOAT NOT NULL	
);

-------------------------------------------

CREATE OR REPLACE TABLE Fact_SRCSalesTarget(
  DimStoreID INT CONSTRAINT FK_FactSalesDimStore FOREIGN KEY
        REFERENCES DIM_Store (DimStoreID) NOT NULL
  ,DimResellerID INT CONSTRAINT FK_FactSalesDimReseller FOREIGN KEY
        REFERENCES DIM_Reseller (DimResellerID) NOT NULL
  ,DimChannelID INT CONSTRAINT FK_FactSalesDimChannel FOREIGN KEY
        REFERENCES DIM_Channel (DimChannelID) NOT NULL
  ,DimTargetDateID NUMBER(9) CONSTRAINT FK_FactSalesDimDate FOREIGN KEY
        REFERENCES DIM_Date (Date_PKey) NOT NULL
  ,SalesTargetAmount INT	
);

--------------------------------------------

CREATE OR REPLACE TABLE Fact_ProductSalesTarget(
   DimProductID INT CONSTRAINT FK_FactSalesDimProduct FOREIGN KEY
        REFERENCES DIM_PRODUCT (DimProductID) NOT NULL
  ,DimTargetDateID NUMBER(9) CONSTRAINT FK_FactSalesDimDate FOREIGN KEY
        REFERENCES DIM_Date (Date_PKey) NOT NULL
  ,ProductTargetSalesQuantity INT	
);

------------------------------------------------

insert into fact_productSalesTarget
(
    DimProductID,
    DimTargetDateID,
    ProductTargetSalesQuantity
)
SELECT distinct 
    p.DimProductID,
    d.Date_PKey,
    spst.SalesQuantityTarget
FROM
    Stage_ProductSalesTarget spst
INNER JOIN Dim_Product p
ON p.DimProductID = spst.ProductID
LEFT OUTER JOIN Dim_Date d
ON d.Year = spst.Year;

-----------------------------------------------------

/*INSERT INTO Fact_SRCSalesTarget (
    DimStoreID,
    DimResellerID,
    DimChannelID,
    DimTargetDateID,
    SalesTargetAmount
)
SELECT 
nvl(s.DimStoreID, -1),
nvl(r.DimResellerID, -1),
c.DimChannelID,
d.Date_PKey,
ssst.TargetSalesAmount
FROM
Stage_SRCSalesTarget ssst
JOIN Dim_Channel c
ON c.ChannelName = CASE when ssst.ChannelName = 'Online' then 'On-line' else ssst.ChannelName end
LEFT OUTER JOIN Dim_Store s
ON ssst.TargetName = 'Store Number ' || s.StoreName
LEFT OUTER JOIN Dim_Reseller r
ON ssst.TargetName = CASE WHEN r.ResellerName = 'Mississipi Distributors' then 'Mississippi Distributors' else r.ResellerName end
LEFT OUTER JOIN Dim_Date d
ON d.Year = ssst.Year
*/

INSERT INTO Fact_SRCSalesTarget (
    DimStoreID,
    DimResellerID,
    DimChannelID,
    DimTargetDateID,
    SalesTargetAmount
)
select distinct
CASE
       WHEN targetname = 'Store Number 5' then 5
       WHEN targetname = 'Store Number 8' then 8
       WHEN targetname = 'Store Number 10' then 10
       WHEN targetname = 'Store Number 21' then 21
       WHEN targetname = 'Store Number 34' then 34
       WHEN targetname = 'Store Number 39' then 39
       else -1
END as storeid,
NVL(r.Dimresellerid, -1) as resellerid,
c.DimChannelID,
d.date_pkey,
src.targetSalesAmount
from stage_srcsalestarget src
INNER JOIN Dim_Channel c
ON c.ChannelName = CASE when src.ChannelName = 'Online' then 'On-line' else src.ChannelName end
LEFT OUTER JOIN Dim_Store s
LEFT OUTER JOIN Dim_Reseller r
ON src.TargetName = CASE WHEN r.ResellerName = 'Mississipi Distributors' then 'Mississippi Distributors' else r.ResellerName end
LEFT OUTER JOIN Dim_Date d
on src.Year = d.Year


------------------------------------
/****************** 2013-01-01 DNE ********************/
INSERT INTO Fact_SalesActual (
    DimProductID,
    DimStoreID,
    DimResellerID,
    DimCustomerID,
    DimChannelID,
    DimSaleDateID,
    DimLocationID,
    SalesHeaderID,
    SalesDetailID,
    SaleAmount,
    SaleQuantity,
    SaleUnitPrice,
    SaleExtenedCost,
    SaleTotalProfit
)
SELECT
*
FROM 
Stage_SalesDetail sd
JOIN Stage_SalesHeader sh 
ON sd.SalesHeaderID = sh.SalesHeaderID
JOIN Dim_Product p 
ON sd.ProductID = p.ProductID
LEFT OUTER JOIN Dim_Store s
ON sh.StoreID = s.SourceStoreID
LEFT OUTER JOIN Dim_Reseller r
on sh.ResellerID = r.ResellerID
LEFT OUTER JOIN Dim_Customer c
on sh.CustomerID = c.CustomerID
LEFT OUTER JOIN Dim_Location l
ON CASE
    WHEN sh.StoreID is not null then s.DimLocationID = l.DimLocationID
    WHEN sh.ResellerID is not null then r.DimLocationID = l.DimLocationID
    WHEN sh.CustomerID is not null then c.DimLocationID = l.DimLocationID
END
LEFT OUTER JOIN Dim_Date d
on sh.Date = d.Date

/****************** 2013-01-01 DNE ********************/