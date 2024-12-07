select * from customer


#Recency (R): Calculate how recently each customer made a purchase.

SELECT CustomerID, 
       MAX(PurchaseDate) AS LastPurchaseDate,
       CURRENT_DATE - MAX(PurchaseDate) AS Recency
FROM Customer  
GROUP BY CustomerID;



#Frequency (F): Calculate how often each customer makes a purchase.

SELECT CustomerID, COUNT(*) AS Frequency
FROM Customer
GROUP BY CustomerID;



#Monetary (M): Calculate the total money spent by each customer.

SELECT CustomerID, SUM(TransactionAmount) AS Monetary
FROM Customer
GROUP BY CustomerID;



#After calculating each metric in separate queries or as subqueries, you would join them together. 

SELECT R.CustomerID, R.Recency, F.Frequency, M.Monetary
FROM (
    SELECT CustomerID, CURRENT_DATE - MAX(PurchaseDate) AS Recency 
    FROM Customer  
    GROUP BY CustomerID
) R
JOIN (
    SELECT CustomerID, COUNT(*) AS Frequency
    FROM Customer  
    GROUP BY CustomerID
) F ON R.CustomerID = F.CustomerID
JOIN (
    SELECT CustomerID, SUM(TransactionAmount) AS Monetary
    FROM Customer 
    GROUP BY CustomerID
) M ON R.CustomerID = M.CustomerID;



# With the RFM scores available, you can classify customers into segments using SQL CASE statements.

WITH CombinedRFMTable AS (
    SELECT R.CustomerID, 
           CURRENT_DATE - MAX(R.PurchaseDate) AS Recency,  
           COUNT(F.CustomerID) AS Frequency,  
           SUM(M.TransactionAmount) AS Monetary  
    FROM Customer R
    JOIN Customer F ON R.CustomerID = F.CustomerID
    JOIN Customer M ON R.CustomerID = M.CustomerID
    GROUP BY R.CustomerID
)
SELECT CustomerID,
       CASE
           WHEN Recency <= 30 THEN 'High'
           WHEN Recency BETWEEN 31 AND 60 THEN 'Medium'
           ELSE 'Low'
       END AS RecencyScore,
       CASE
           WHEN Frequency >= 10 THEN 'High'
           WHEN Frequency BETWEEN 5 AND 9 THEN 'Medium'
           ELSE 'Low'
       END AS FrequencyScore,
       CASE
           WHEN Monetary >= 500 THEN 'High'
           WHEN Monetary BETWEEN 200 AND 499 THEN 'Medium'
           ELSE 'Low'
       END AS MonetaryScore
FROM CombinedRFMTable;
