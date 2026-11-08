-- Seminar 7 - Zadanie 1d - Northwind: schema snehovej vlocky (snowflake)
--
-- Grain faktovej tabulky: jeden riadok = jedna polozka objednavky (OrderDetails).
-- Fakty:      quantity, unit_price, sales_amount
-- Dimenzie:   cas, zakaznik, produkt, zamestnanec, prepravca
-- Snowflake:  produkt -> kategoria, produkt -> dodavatel,
--             zakaznik / dodavatel -> mesto -> krajina
--
-- Kazda dimenzia ma vlastny surrogate key (*_key) a povodny business key (*_id) zo zdroja.

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_category;
DROP TABLE IF EXISTS dim_supplier;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_city;
DROP TABLE IF EXISTS dim_country;
DROP TABLE IF EXISTS dim_employee;
DROP TABLE IF EXISTS dim_shipper;
DROP TABLE IF EXISTS dim_date;

-- Casova dimenzia (date_key vo formate YYYYMMDD, napr. 19960704)
CREATE TABLE dim_date (
    date_key     INT PRIMARY KEY,
    full_date    DATE        NOT NULL UNIQUE,
    day          SMALLINT    NOT NULL,
    month        SMALLINT    NOT NULL,
    month_name   VARCHAR(15) NOT NULL,
    quarter      SMALLINT    NOT NULL,
    year         SMALLINT    NOT NULL,
    day_of_week  SMALLINT    NOT NULL,
    day_name     VARCHAR(15) NOT NULL,
    is_weekend   BOOLEAN     NOT NULL
);

-- Geografia (normalizovana cast snehovej vlocky)
CREATE TABLE dim_country (
    country_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_name VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE dim_city (
    city_key     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_name    VARCHAR(20) NOT NULL,
    country_key  INT NOT NULL REFERENCES dim_country (country_key),
    UNIQUE (city_name, country_key)
);

CREATE TABLE dim_customer (
    customer_key   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id    INT         NOT NULL UNIQUE,
    customer_name  VARCHAR(50) NOT NULL,
    contact_name   VARCHAR(50),
    address        VARCHAR(50),
    postal_code    VARCHAR(10),
    city_key       INT REFERENCES dim_city (city_key)
);

CREATE TABLE dim_supplier (
    supplier_key   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_id    INT         NOT NULL UNIQUE,
    supplier_name  VARCHAR(50) NOT NULL,
    contact_name   VARCHAR(50),
    address        VARCHAR(50),
    postal_code    VARCHAR(10),
    phone          VARCHAR(15),
    city_key       INT REFERENCES dim_city (city_key)
);

CREATE TABLE dim_category (
    category_key   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id    INT          NOT NULL UNIQUE,
    category_name  VARCHAR(25)  NOT NULL,
    description    VARCHAR(255)
);

CREATE TABLE dim_product (
    product_key    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id     INT           NOT NULL UNIQUE,
    product_name   VARCHAR(50)   NOT NULL,
    unit           VARCHAR(25),
    list_price     NUMERIC(10, 2),
    category_key   INT NOT NULL REFERENCES dim_category (category_key),
    supplier_key   INT NOT NULL REFERENCES dim_supplier (supplier_key)
);

CREATE TABLE dim_employee (
    employee_key   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id    INT         NOT NULL UNIQUE,
    first_name     VARCHAR(15) NOT NULL,
    last_name      VARCHAR(15) NOT NULL,
    full_name      VARCHAR(31) NOT NULL,
    birth_date     DATE
);

CREATE TABLE dim_shipper (
    shipper_key    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipper_id     INT         NOT NULL UNIQUE,
    shipper_name   VARCHAR(25) NOT NULL,
    phone          VARCHAR(15)
);

-- Faktova tabulka predaja
CREATE TABLE fact_sales (
    sales_key        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_detail_id  INT NOT NULL UNIQUE,   -- degenerovana dimenzia (OrderDetails.OrderDetailID)
    order_id         INT NOT NULL,          -- degenerovana dimenzia (Orders.OrderID)
    date_key         INT NOT NULL REFERENCES dim_date (date_key),
    customer_key     INT NOT NULL REFERENCES dim_customer (customer_key),
    product_key      INT NOT NULL REFERENCES dim_product (product_key),
    employee_key     INT NOT NULL REFERENCES dim_employee (employee_key),
    shipper_key      INT NOT NULL REFERENCES dim_shipper (shipper_key),
    quantity         INT            NOT NULL,
    unit_price       NUMERIC(10, 2) NOT NULL,
    sales_amount     NUMERIC(12, 2) NOT NULL   -- quantity * unit_price
);

-- Indexy nad cudzimi klucmi faktovej tabulky (PostgreSQL ich nevytvara automaticky)
CREATE INDEX idx_fact_sales_date     ON fact_sales (date_key);
CREATE INDEX idx_fact_sales_customer ON fact_sales (customer_key);
CREATE INDEX idx_fact_sales_product  ON fact_sales (product_key);
CREATE INDEX idx_fact_sales_employee ON fact_sales (employee_key);
CREATE INDEX idx_fact_sales_shipper  ON fact_sales (shipper_key);
