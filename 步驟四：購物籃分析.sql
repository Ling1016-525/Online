-- 第一步：刪除舊表
DROP TABLE IF EXISTS tmp_valid_items;

-- 第二步：建立實體表
CREATE TABLE tmp_valid_items (
    InvoiceNo VARCHAR(50),
    StockCode VARCHAR(50),
    Description VARCHAR(255)
);

-- 第三步：寫入精簡後的資料（限制熱門商品與合理訂單規模）
INSERT INTO tmp_valid_items
WITH item_counts AS (
    -- 1. 找出出現超過 15 次的熱門商品
    SELECT StockCode
    FROM online_clean
    WHERE Description IS NOT NULL AND Quantity > 0
    GROUP BY StockCode
    HAVING COUNT(DISTINCT InvoiceNo) >= 15
),
normal_invoices AS (
    -- 2. 排除超過 30 樣商品的巨型發票（避免 Self-Join 組合數爆炸）
    SELECT InvoiceNo
    FROM online_clean
    WHERE Description IS NOT NULL AND Quantity > 0
    GROUP BY InvoiceNo
    HAVING COUNT(DISTINCT StockCode) <= 30
)
SELECT DISTINCT 
    o.InvoiceNo, 
    o.StockCode, 
    o.Description
FROM online_clean o
JOIN item_counts ic ON o.StockCode = ic.StockCode
JOIN normal_invoices ni ON o.InvoiceNo = ni.InvoiceNo
WHERE o.Description NOT IN ('POSTAGE', 'MANUAL', 'DOTCOM POSTAGE', 'AMAZON FEE', 'BANK CHARGES')
  AND o.Quantity > 0;

-- 第四步：建立複合索引
CREATE INDEX idx_invoice_stock ON tmp_valid_items (InvoiceNo, StockCode);

-- 第五步：執行購物籃分析（此時資料已極度輕量化，可在數秒內完成！）
SELECT 
    a.Description AS `商品 A`,
    b.Description AS `商品 B`,
    COUNT(*) AS `同時購買次數`
FROM tmp_valid_items a
JOIN tmp_valid_items b 
    ON a.InvoiceNo = b.InvoiceNo 
   AND a.StockCode < b.StockCode
GROUP BY a.Description, b.Description
ORDER BY `同時購買次數` DESC
LIMIT 10;

-- 第六步：分析完成後順手清理資料庫（選填）
-- DROP TABLE IF EXISTS tmp_valid_items;



