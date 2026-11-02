
--For each order: products included, quantity and Net & Gross sales per line order by date
create or alter view vw_factsales as 
select distinct o.OrderId , o.OrderDate,p.ProductName , od.UnitPrice,od.Quantity,od.Discount,
 od.UnitPrice * od.Quantity AS GrossSales,
    od.UnitPrice * od.Quantity * (1 - od.Discount) AS NetSales
from Orders o 
left join [Order Details] od
on o.OrderId=od.OrderID
left join Products p
on od.ProductID= p.ProductID

Go

--Ranking by NetSales & Rank by NetSales TotalUnitsold
create or alter view vw_productranking as 
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

Go





--Customer Analysis

--Numbers of orders, Netsales, TotalUnitSold per customer
create or alter view vw_CustomerAnalysis as 
select c.CustomerID,c.CompanyName,count(distinct o.OrderID) as OrderNumber ,
sum(od.quantity) as TotalUnitSold,
cast( sum(od.quantity * od.UnitPrice* (1-od.Discount))as Decimal(18,0)) as Netsales
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
inner join [Order Details] as od 
on od.OrderID= o.OrderID
group by c.CustomerID,c.CompanyName

Go

--Top 10 Customers by sales
create or alter view vw_Top10Customers as 
select Top 10 c.CustomerID,c.CompanyName,
cast( sum(od.quantity * od.UnitPrice* (1-od.Discount))as Decimal(18,0)) as Netsales
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
inner join [Order Details] as od 
on od.OrderID= o.OrderID
group by c.CustomerID,c.CompanyName
order by sum(od.quantity * od.UnitPrice* (1-od.Discount)) desc
Go

--Customer Ranking by Number of orders
create or alter view vw_CustomerOrderRanking as 
select c.CustomerID,c.CompanyName,count(distinct o.OrderID) as OrderNumber 
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
group by c.CustomerID,c.CompanyName

Go
--Average order value per customer
create or alter view vw_AverageOrder as 
select c.CustomerID,c.CompanyName,
cast( Avg(od.quantity * od.UnitPrice* (1-od.Discount))as Decimal(18,0)) as AvgNetsales
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
inner join [Order Details] as od 
on od.OrderID= o.OrderID
group by c.CustomerID,c.CompanyName

Go
--Customers with only 1 order
create or alter view vw_SingleOrderCustomer as 
select c.CustomerID,c.CompanyName,count(distinct o.OrderID) as OrderNumber 
from  Customers as c
inner join Orders as o
On c.CustomerID = o.CustomerID
group by c.CustomerID,c.CompanyName
having count(distinct o.OrderID)=1

Go
--Sales concentration among top customers
create or alter view vw_SalesConcentration as 
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
Go
--Sales Analysis by Discount Level
create or alter view vw_DiscountAnalysis as 
select  (Discount *100) as DiscountPercentage ,
 count(distinct OrderID) as TotalOrders,
 sum(Quantity) as TotalUnitsSold,
 Cast(Round(sum(UnitPrice * Quantity)                  ,0) as Decimal(10,0)) as GrossSales,
 Cast(Round(sum(UnitPrice * Quantity * (1 - Discount)) ,0) as Decimal(10,0)) as NetSales,
 Cast(Round(sum(UnitPrice * Quantity * Discount)       ,0) as Decimal(10,0)) as DiscountAmount
from [Order Details] 
group by Discount


Go
--TotalOrders, Non/DiscountedOrders, Non/Discounted orders percentage
create or alter view vw_DiscountTotals as 
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

 


 Go
 --Shipping Analysis

 --Time between orderdate & shippingdate
 create or alter view vw_ShippingTime as 
 select OrderID, OrderDate, ShippedDate,
 DATEDIFF(day,OrderDate, ShippedDate) as OrdertoShipTime
 from Orders
 where  DATEDIFF(day,OrderDate, ShippedDate) is not null


 Go
 --Average shipping date
 create or alter view vw_AverageShippingTime as 
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


 ---- On-Time vs Late Shipping (Full dataset)
 --create or alter view vw_ShippingStatus as 
 --select *,
 -- case when requireddate < shippeddate then 'On-Time'
 -- else 'Late' End
 -- as ShippingStatus
 --from orders 
 --where requireddate is not null And shippeddate is not null

 Go
 -- On-Time vs Late Shipping 
 create or alter view vw_ShippingStatus as 
 select orderid,requireddate,shippeddate,
 case when requireddate > shippeddate then 'On-Time'
  else 'Late' End
  as ShippingStatus
 from orders 
 where requireddate is not null And shippeddate is not null

 



