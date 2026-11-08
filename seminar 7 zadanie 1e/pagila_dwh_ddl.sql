-- Seminar 7 - Zadanie 1e - Pagila: schema snehovej vlocky (snowflake)
--
-- Grain faktovej tabulky: jeden riadok = jedna vypozicka (rental) jednej kopie filmu (inventory).
-- Fakty:      rental_amount, planned_rental_days, actual_rental_days, rental_count
-- Dimenzie:   cas (datum vypozicky aj vratenia), zakaznik, film, zamestnanec, predajna
-- Snowflake:  film -> jazyk, zakaznik / predajna -> adresa -> mesto -> krajina,
--             zamestnanec -> predajna
-- Bridge:     film <-> kategoria, film <-> herec (vztahy M:N zo zdrojovej schemy)
--
-- Kazda dimenzia ma vlastny surrogate key (*_key) a povodny business key (*_id) zo zdroja.
-- Tabulka inventory sa do skladu nepreberá ako dimenzia: kopia filmu je rozlozena
-- na film_key + store_key a inventory_id zostava ako degenerovana dimenzia vo fakte.

DROP TABLE IF EXISTS fact_rental;
DROP TABLE IF EXISTS bridge_film_category;
DROP TABLE IF EXISTS bridge_film_actor;
DROP TABLE IF EXISTS dim_category;
DROP TABLE IF EXISTS dim_actor;
DROP TABLE IF EXISTS dim_film;
DROP TABLE IF EXISTS dim_language;
DROP TABLE IF EXISTS dim_staff;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_address;
DROP TABLE IF EXISTS dim_city;
DROP TABLE IF EXISTS dim_country;
DROP TABLE IF EXISTS dim_date;

-- Casova dimenzia (date_key vo formate YYYYMMDD, napr. 20220524)
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
    country_id   INT         NOT NULL UNIQUE,
    country      VARCHAR(50) NOT NULL
);

CREATE TABLE dim_city (
    city_key     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_id      INT         NOT NULL UNIQUE,
    city         VARCHAR(50) NOT NULL,
    country_key  INT NOT NULL REFERENCES dim_country (country_key)
);

CREATE TABLE dim_address (
    address_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address_id   INT         NOT NULL UNIQUE,
    address      VARCHAR(50) NOT NULL,
    address2     VARCHAR(50),
    district     VARCHAR(20),
    postal_code  VARCHAR(10),
    phone        VARCHAR(20),
    city_key     INT NOT NULL REFERENCES dim_city (city_key)
);

CREATE TABLE dim_customer (
    customer_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   INT         NOT NULL UNIQUE,
    first_name    VARCHAR(45) NOT NULL,
    last_name     VARCHAR(45) NOT NULL,
    email         VARCHAR(50),
    active        BOOLEAN     NOT NULL,
    created_at    DATE,
    address_key   INT NOT NULL REFERENCES dim_address (address_key)
);

CREATE TABLE dim_store (
    store_key           INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    store_id            INT         NOT NULL UNIQUE,
    manager_first_name  VARCHAR(45),
    manager_last_name   VARCHAR(45),
    address_key         INT NOT NULL REFERENCES dim_address (address_key)
);

CREATE TABLE dim_staff (
    staff_key    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    staff_id     INT         NOT NULL UNIQUE,
    first_name   VARCHAR(45) NOT NULL,
    last_name    VARCHAR(45) NOT NULL,
    email        VARCHAR(50),
    username     VARCHAR(16) NOT NULL,
    active       BOOLEAN     NOT NULL,
    store_key    INT NOT NULL REFERENCES dim_store (store_key)
);

CREATE TABLE dim_language (
    language_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    language_id   INT         NOT NULL UNIQUE,
    name          VARCHAR(20) NOT NULL
);

CREATE TABLE dim_film (
    film_key          INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    film_id           INT          NOT NULL UNIQUE,
    title             VARCHAR(255) NOT NULL,
    description       TEXT,
    release_year      SMALLINT,
    rental_duration   SMALLINT     NOT NULL,
    rental_rate       NUMERIC(4, 2) NOT NULL,
    length            SMALLINT,
    replacement_cost  NUMERIC(5, 2) NOT NULL,
    rating            VARCHAR(10),
    special_features  TEXT,
    language_key      INT NOT NULL REFERENCES dim_language (language_key)
);

CREATE TABLE dim_category (
    category_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id   INT         NOT NULL UNIQUE,
    name          VARCHAR(25) NOT NULL
);

CREATE TABLE dim_actor (
    actor_key    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    actor_id     INT         NOT NULL UNIQUE,
    first_name   VARCHAR(45) NOT NULL,
    last_name    VARCHAR(45) NOT NULL
);

-- Bridge tabulky pre vztahy M:N (film moze mat viac kategorii a viac hercov)
CREATE TABLE bridge_film_category (
    film_key      INT NOT NULL REFERENCES dim_film (film_key),
    category_key  INT NOT NULL REFERENCES dim_category (category_key),
    PRIMARY KEY (film_key, category_key)
);

CREATE TABLE bridge_film_actor (
    film_key   INT NOT NULL REFERENCES dim_film (film_key),
    actor_key  INT NOT NULL REFERENCES dim_actor (actor_key),
    PRIMARY KEY (film_key, actor_key)
);

-- Faktova tabulka vypoziciek
CREATE TABLE fact_rental (
    rental_key           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rental_id            INT NOT NULL UNIQUE,   -- degenerovana dimenzia (rental.rental_id)
    inventory_id         INT NOT NULL,          -- degenerovana dimenzia (inventory.inventory_id)
    rental_date_key      INT NOT NULL REFERENCES dim_date (date_key),
    return_date_key      INT REFERENCES dim_date (date_key),   -- NULL = film este nebol vrateny
    customer_key         INT NOT NULL REFERENCES dim_customer (customer_key),
    film_key             INT NOT NULL REFERENCES dim_film (film_key),
    staff_key            INT NOT NULL REFERENCES dim_staff (staff_key),
    store_key            INT NOT NULL REFERENCES dim_store (store_key),
    rental_amount        NUMERIC(5, 2) NOT NULL,   -- film.rental_rate v case vypozicky
    planned_rental_days  SMALLINT      NOT NULL,   -- film.rental_duration
    actual_rental_days   SMALLINT,                 -- return_date - rental_date
    rental_count         SMALLINT      NOT NULL DEFAULT 1
);

-- Indexy nad cudzimi klucmi faktovej tabulky
CREATE INDEX idx_fact_rental_rental_date ON fact_rental (rental_date_key);
CREATE INDEX idx_fact_rental_return_date ON fact_rental (return_date_key);
CREATE INDEX idx_fact_rental_customer    ON fact_rental (customer_key);
CREATE INDEX idx_fact_rental_film        ON fact_rental (film_key);
CREATE INDEX idx_fact_rental_staff       ON fact_rental (staff_key);
CREATE INDEX idx_fact_rental_store       ON fact_rental (store_key);
