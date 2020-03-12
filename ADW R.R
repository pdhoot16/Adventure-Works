install.packages("RODBC")

require(RODBC)

conn <- odbcDriverConnect("driver={SQL Server};server=LAPTOP-72BLL3OI\\SQLEXPRESS;database=AdventureWorksDW2014; trusted_connection=true;")
conn


q1 <- sqlQuery(conn,"select top 5 sum(f.OrderQuantity) value, g.City, r.ResellerName
from FactResellerSales f
inner join DimProduct d
on f.ProductKey = d.ProductKey
inner join DimReseller r
on f.ResellerKey = r.ResellerKey
inner join DimGeography g
on r.GeographyKey = g.GeographyKey
group by g.City, r.ResellerName
order by sum(f.OrderQuantity) desc")
q1

plot(q1$ResellerName, q1$value, xlab= "Reseller", ylab = "Number of Orders", 
     main = "Reseller's Order Summary")




 
# --Most sold products in a particular city
q2 <- sqlQuery(conn,"select top 5 sum(f.OrderQuantity) OrderCount, g.City, r.ResellerName
from FactResellerSales f
inner join DimProduct d
on f.ProductKey = d.ProductKey
inner join DimReseller r
on f.ResellerKey = r.ResellerKey
inner join DimGeography g
on r.GeographyKey = g.GeographyKey
where g.City = 'Toronto'
group by g.City, r.ResellerName
order by sum(f.OrderQuantity) desc")
q2

pie(q2$OrderCount, labels = paste(q2$ResellerName,q2$OrderCount),col = sample(colors()),main = "Most Popular Resellers in Toronto")

# --Products with max discount
q3 <- sqlQuery(conn,"select d.EnglishProductName, f.DiscountAmount, d.ProductLine
from FactResellerSales f
inner join DimProduct d
on f.ProductKey = d.ProductKey
where f.DiscountAmount > 100
order by f.DiscountAmount desc")
View(q3)

boxplot(q3$DiscountAmount~q3$ProductLine, xlab = "Product Line", ylab = "Discount Amount", 
        main= "Discount Range in each Product Line")

# 
# --Sales in every Quarter -- Trend
q4 <- sqlQuery(conn,"select concat('Q',d.CalendarQuarter) Quarter, sum(SalesAmount) Sales
from FactResellerSales f
               inner join DimDate d
               on f.OrderDateKey = d.DateKey
               group by d.CalendarQuarter")
plot(q4$Quarter,q4$Sales,
        type = "l", xlab = "Quarter", ylab = "Sales", main = "Quarterly Sales Report")
