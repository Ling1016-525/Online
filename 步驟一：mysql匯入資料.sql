-- 1. 先建立一個乾淨的資料表結構
CREATE TABLE IF NOT EXISTS online_retail (
    InvoiceNo TEXT,
    StockCode TEXT,
    Description TEXT,
    Quantity INT,
    InvoiceDate TEXT,
    UnitPrice DOUBLE,
    CustomerID TEXT,
    Country TEXT
);

-- 2. 清空可能殘留的舊資料
TRUNCATE TABLE online_retail;

-- 3. 瞬間匯入 54 萬筆資料（請把下面的檔案路徑改成你電腦上的實際路徑）
LOAD DATA LOCAL INFILE 'C:/Users/SCE/Desktop/online/online_retail_cleaned.csv'
INTO TABLE online_retail
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- 忽略第一行的表頭

-- 4. 檢查有沒有成功進去
SELECT * FROM online_retail LIMIT 10;
