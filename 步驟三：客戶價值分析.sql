-- 4. 客戶價值分析 (RFM Model)

/*
為什麼要這樣寫？不用 NOW() 嗎？因為這張 online_clean 資料集是好幾年前的歷史資料
（例如 2010 或 2011 年的電商公開資料）。如果用 NOW()（2026年）去減，
算出來的 Recency 每個人都是四千多天，分析就失去意義了。所以寫這段語法的人非常聰明，
他用「商店營業的最後一天」來假裝是「今天」，這樣算出來的 Recency 
才是最符合歷史情境的正確天數！
*/

WITH Yearly_Max_Date AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(InvoiceDate, '%Y-%m-%d %H:%i:%s'), '%Y') AS InvoiceYear,
        MAX(STR_TO_DATE(InvoiceDate, '%Y-%m-%d %H:%i:%s')) AS MaxYearDate
    FROM online_clean
    GROUP BY DATE_FORMAT(STR_TO_DATE(InvoiceDate, '%Y-%m-%d %H:%i:%s'), '%Y')
),
Customer_RFM_Yearly AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(o.InvoiceDate, '%Y-%m-%d %H:%i:%s'), '%Y') AS InvoiceYear,
        o.CustomerID,
        DATEDIFF(m.MaxYearDate, MAX(STR_TO_DATE(o.InvoiceDate, '%Y-%m-%d %H:%i:%s'))) AS Recency,
        COUNT(DISTINCT o.InvoiceNo) AS Frequency,
        ROUND(SUM(o.Quantity * o.UnitPrice), 2) AS Monetary
    FROM online_clean as o
    JOIN Yearly_Max_Date as m 
        ON DATE_FORMAT(STR_TO_DATE(o.InvoiceDate, '%Y-%m-%d %H:%i:%s'), '%Y') = m.InvoiceYear
    WHERE o.CustomerID IS NOT NULL AND o.CustomerID != ''
    GROUP BY DATE_FORMAT(STR_TO_DATE(o.InvoiceDate, '%Y-%m-%d %H:%i:%s'), '%Y'), o.CustomerID, m.MaxYearDate
),
Customer_Segmented AS (
    SELECT 
        InvoiceYear,
        CustomerID,
        Monetary,
        CASE 
            WHEN Frequency >= 10 AND Monetary >= 5000 THEN '1. 核心 VIP 客戶'
            WHEN Recency <= 30 AND Frequency >= 3 THEN '2. 高潛力新客戶'
            WHEN Recency > 180 AND Frequency >= 3 THEN '3. 易流失老客戶'
            WHEN Recency > 180 AND Frequency <= 1 THEN '4. 已流失低價值客戶'
            ELSE '5. 一般常客'
        END AS Segment
    FROM Customer_RFM_Yearly
)
-- 關鍵修改：在 SQL 就做分群統計，資料量從幾千筆縮減至每年僅 5 筆！
SELECT 
    InvoiceYear AS '年份',
    Segment AS '客戶分群',
    COUNT(CustomerID) AS '客群人數',
    ROUND(SUM(Monetary), 2) AS '客群總營收',
    ROUND(AVG(Monetary), 2) AS '客群平均客單價'
FROM Customer_Segmented
GROUP BY InvoiceYear, Segment
ORDER BY InvoiceYear DESC, Segment ASC;
