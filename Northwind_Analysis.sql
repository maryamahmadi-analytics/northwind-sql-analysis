--Initial Data Review:

--Records Numder:
select count(*) as ProductsRowsNumber from Products 
select count(*) as OrderRowsNumber from Orders 
select count(*) as ODetailsRowsNumber from [Order Details] 

--Check for column name, Data type, Nullable:
select column_name, 
data_type, 
is_Nullable,                       -- SupplierID,CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder,ReorderLevel are Nullable
character_maximum_length
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Products'
order by ORDINAL_POSITION;


--Check for Null in the columns:
select * from Products
where UnitPrice is null or SupplierID is null     -- or for other columns
--No Null values found in 2 columns

--Check for all the columns:
select count(*) as TotalRows,
sum(
case when SupplierID is null  then 1 else 0 end
) as NullSupplierID,
sum(
case when CategoryID is null  then 1 else 0 end
) as NullCategoryID,
sum(
case when QuantityPerUnit is null  then 1 else 0 end
) as NullQuantityPerUnit,
sum(
case when UnitPrice is null  then 1 else 0 end
) as NullUnitPrice,
sum(
case when UnitsInStock is null  then 1 else 0 end
) as NullUUnitsInStock,
sum(
case when UnitsOnOrder is null  then 1 else 0 end
) as NullUnitsOnOrder,
sum(
case when ReorderLevel is null  then 1 else 0 end
) as NullReorderLevel
 from Products
 --100% sure there are no Nulls in any of the columns


 --check for unusual values     -- e.g. UnitPrice<0
select * from Products
where UnitPrice<0 or UnitPrice=0
-- Price values are usual



--For each order: products included, quantity and Net & Gross sales per line order by date

select distinct o.OrderId , o.OrderDate,p.ProductName , od.UnitPrice,od.Quantity,od.Discount,
 od.UnitPrice * od.Quantity AS GrossSales,
    od.UnitPrice * od.Quantity * (1 - od.Discount) AS NetSales
from Orders o 
left join [Order Details] od
on o.OrderId=od.OrderID
left join Products p
on od.ProductID= p.ProductID
ORDER BY o.OrderDate;




--Ranking by NetSales & Rank by NetSales TotalUnitsold
select distinct p.ProductName , p.ProductID,sum(od.Quantity) as TUnitsold,
 sum(od.UnitPrice * od.Quantity) AS GrossSales,
  sum(  od.UnitPrice * od.Quantity * (1 - od.Discount) )AS NetSales,
    Rank() over ( 
ORDER BY sum(  od.UnitPrice * od.Quantity * (1 - od.Discount) ) Desc) as NetSalesRank,
 Rank() over (
ORDER BY sum(od.Quantity) Desc) as TUnitsoldRank
from Orders o 
left join [Order Details] od
on o.OrderId=od.OrderID
left join Products p
on od.ProductID= p.ProductID
group by p.ProductID, p.ProductName
order by NetSalesRank


--Customer Analysis

--Numbers of orders, Netsales, TotalUnitSold per customer
select c.CustomerID,c.CompanyName,count(distinct o.OrderID) as OrderNumber ,
sum(od.quantity) as TotalUnitSold,
cast( sum(od.quantity * od.UnitPrice* (1-od.Discount))as Decimal(18,0)) as Netsales
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
inner join [Order Details] as od 
on od.OrderID= o.OrderID
group by c.CustomerID,c.CompanyName
Order by Netsales desc


--Top 10 Customers by sales
select Top 10 c.CustomerID,c.CompanyName,
cast( sum(od.quantity * od.UnitPrice* (1-od.Discount))as Decimal(18,0)) as Netsales
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
inner join [Order Details] as od 
on od.OrderID= o.OrderID
group by c.CustomerID,c.CompanyName
Order by Netsales desc

--Customer Ranking by Number of orders
select c.CustomerID,c.CompanyName,count(distinct o.OrderID) as OrderNumber 
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
group by c.CustomerID,c.CompanyName
Order by OrderNumber desc

--Average order value per customer
select c.CustomerID,c.CompanyName,
cast( Avg(od.quantity * od.UnitPrice* (1-od.Discount))as Decimal(18,0)) as AvgNetsales
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
inner join [Order Details] as od 
on od.OrderID= o.OrderID
group by c.CustomerID,c.CompanyName
Order by AvgNetsales desc


--Customers with only 1 order
select c.CustomerID,c.CompanyName,count(distinct o.OrderID) as OrderNumber 
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
group by c.CustomerID,c.CompanyName
having count(distinct o.OrderID)=1


--Sales concentration among top customers

select Cast(Round(
      (
select sum(TC.Netsales) as Top10TotalSales 
from
(select Top 10 
cast( sum (od.quantity * od.UnitPrice* (1-od.Discount))as Decimal(18,0)) as Netsales
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
inner join [Order Details] as od 
on od.OrderID= o.OrderID
group by c.CustomerID) as TC
      )
/
(
select (
select sum(TC.Netsales) as TotalSales 
from(
select
cast( sum (od.quantity * od.UnitPrice* (1-od.Discount))as Decimal(18,0)) as Netsales
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
inner join [Order Details] as od 
on od.OrderID= o.OrderID
group by c.CustomerID) as TC))*100
,2)
As Decimal(10,2))
as 'Top10TotalSales%'



--Discount Analysis

--Sales Analysis by Discount Level
select  (Discount *100) as DiscountPercentage ,
 count(distinct OrderID) as TotalOrders,
 sum(Quantity) as TotalUnitsSold,
 Cast(Round(sum(UnitPrice * Quantity)                  ,0) as Decimal(10,0)) as GrossSales,
 Cast(Round(sum(UnitPrice * Quantity * (1 - Discount)) ,0) as Decimal(10,0)) as NetSales,
 Cast(Round(sum(UnitPrice * Quantity * Discount)       ,0) as Decimal(10,0)) as DiscountAmount
from [Order Details] 
group by Discount
order by Discount;



--TotalOrders, Non/DiscountedOrders, Non/Discounted orders percentage
select Count(*) as TotalOrders,
 ( select Count(*) 
   from [Order Details] 
   where Discount > 0 )as DiscountedOrders,

 ( select Count(*) 
   from [Order Details] 
   where Discount = 0 )as NonDiscountedOrders,

 (
   select Cast(Round(
 (
   select sum(s. sales) as DiscountedTotalsales from
    ( select cast(sum(Quantity*UnitPrice) as decimal (10,0)) as sales
      from [Order Details]
      group by Discount
      having Discount>0 
    )as s
 )
 / 
 ( select cast(sum(Quantity*UnitPrice) as decimal (10,0)) as sales
   from [Order Details] as Totalsales
 ) *100 ,2)
   as Decimal(10,2))
 ) as 'DiscountedOrders%',

 (
   select Cast(Round(
 (
   select sum(s. sales) as NonDiscountedTotalsales from
    ( select cast(sum(Quantity*UnitPrice) as decimal (10,0)) as sales 
      from [Order Details]
      group by Discount
      having Discount=0
    ) as s
 )
 / 
 ( select cast(sum(Quantity*UnitPrice) as decimal (10,0)) as sales
   from [Order Details] as Totalsales
 ) *100 ,2)
   as Decimal(10,2))
 ) as 'NonDiscountedOrders%'
from [Order Details] 

 



 --Shipping Analysis

 --Time between orderdate & shippingdate
 select OrderID, OrderDate, ShippedDate,
 DATEDIFF(day,OrderDate, ShippedDate) as OrdertoShipTime
 from Orders
 where  DATEDIFF(day,OrderDate, ShippedDate) is not null
 order by OrdertoShipTime asc


 --Average shipping date
 select
 cast( Avg(
           cast(
           DATEDIFF(day,OrderDate, ShippedDate
                    ) as decimal(10,2)
                 )
          )as decimal(10,2)
     ) as AverageShippingDates
 from Orders
 where ShippedDate is not null


 -- On-Time vs Late Shipping (Full dataset)
 select *,
  case when requireddate < shippeddate then 'On-Time'
  else 'Late' End
  as ShippingStatus
 from orders 
 where requireddate is not null And shippeddate is not null


 -- On-Time vs Late Shipping 
 select orderid,requireddate,shippeddate,
 case when requireddate > shippeddate then 'On-Time'
  else 'Late' End
  as ShippingStatus
 from orders 
 where requireddate is not null And shippeddate is not null

 



