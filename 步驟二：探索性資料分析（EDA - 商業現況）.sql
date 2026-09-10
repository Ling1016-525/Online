-- 1. 整體趨勢：按月份統計銷售額與訂單量
SELECT 
    -- 這裡使用 STR_TO_DATE 把你的文字型態時間，轉換成 MySQL 認得的時間，並抓出年份與月份(data_f)
    -- DATA_FORMATE 是將轉化過後的日期，只保留Y、M
    -- as針對欄位給命名
    DATE_FORMAT(STR_TO_DATE(InvoiceDate, '%Y-%m-%d %H:%i:%s'), '%Y-%m') AS '月份',
    ROUND(SUM(Quantity * UnitPrice), 2) AS '月銷售額',
    -- 加總數量*單價後的金額，並取加總後的銷售額四捨五入至 小數點 2位
    COUNT(DISTINCT InvoiceNo) AS '不重複訂單量'
    -- 計算不重複的訂單(依發票號碼去篩選)
FROM online_clean
WHERE InvoiceDate LIKE '2011%'
group by 月份
-- GROUP BY DATE_FORMAT(STR_TO_DATE(InvoiceDate, '%Y-%m-%d %H:%i:%s'), '%Y-%m')
-- group by 針對列的分類去做統整，group by 後可用別名不需加單引
ORDER BY 1;


-- 2. 主力市場：國家貢獻度排行
SELECT 
    Country AS '國家',
    ROUND(SUM(Quantity * UnitPrice), 2) AS '總銷售額',
    COUNT(DISTINCT InvoiceNo) AS '訂單總數',
    ROUND((SUM(Quantity * UnitPrice) / (SELECT SUM(Quantity * UnitPrice) FROM online_clean)) * 100, 2) AS '銷售額佔比 (%)'
FROM online_clean
GROUP BY Country
ORDER BY 總銷售額 DESC;

-- 3-1. 銷售量前 10 名的商品 (Top 10 by Quantity)
SELECT 
    Description AS '商品名稱',
    SUM(Quantity) AS '總銷售件數'
FROM online_clean
GROUP BY Description
ORDER BY 總銷售件數 DESC
LIMIT 5;

-- 3-2. 銷售額前 10 名的商品 (Top 10 by Revenue)
SELECT 
    Description AS '商品名稱',
    ROUND(SUM(Quantity * UnitPrice), 2) AS '總銷售金額'
FROM online_clean
GROUP BY Description
ORDER BY 總銷售金額 DESC
LIMIT 5;

