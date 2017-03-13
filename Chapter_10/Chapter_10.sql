----------------------------------------------
-- Dig Through Data With SQL
-- by Anthony DeBarros

-- Chapter 10 Code Examples
----------------------------------------------

-- Listing 10-1: Create Census 2015 ACS 5-Year stats table, import data

CREATE TABLE acs_2011_2015_stats (
    geoid varchar(14) CONSTRAINT geoid_key PRIMARY KEY,
    county varchar(50) NOT NULL,
    st varchar(20) NOT NULL,
    pct_travel_60_min numeric(5,3) NOT NULL,
    pct_bachelors_higher numeric(5,3) NOT NULL,
    pct_masters_higher numeric(5,3) NOT NULL,
    median_hh_income integer,
    CHECK (pct_masters_higher <= pct_bachelors_higher)
);

COPY acs_2011_2015_stats
FROM 'C:\YourDirectory\acs_2011_2015_5yr.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM acs_2011_2015_stats;

-- Listing 10-2: Using corr() to measure relationship between education and income

SELECT corr(median_hh_income, pct_bachelors_higher)
    AS bachelors_income_r
FROM acs_2011_2015_stats;

-- Listing 10-3: Using corr() on additional variables

SELECT
    round(
      corr(median_hh_income, pct_bachelors_higher)::numeric, 2
      ) AS bachelors_income_r,
    round(
      corr(pct_travel_60_min, median_hh_income)::numeric, 2
      ) AS income_travel_r,
    round(
      corr(pct_travel_60_min, pct_bachelors_higher)::numeric, 2
      ) AS bachelors_travel_r
FROM acs_2011_2015_stats;

-- Listing 10-4: Regression slope and intercept functions

SELECT
    round(
        regr_slope(median_hh_income, pct_bachelors_higher)::numeric, 2
        ) AS slope,
    round(
        regr_intercept(median_hh_income, pct_bachelors_higher)::numeric, 2
        ) AS y_intercept
FROM acs_2011_2015_stats;

-- Listing 10-5: Calculating the coefficient of determination, or r-squared

SELECT round(
        regr_r2(median_hh_income, pct_bachelors_higher)::numeric, 3
        ) AS r_squared
FROM acs_2011_2015_stats;

-- Additional stats functions. Bonus!
-- Variance
SELECT var_pop(median_hh_income)
FROM acs_2011_2015_stats;

-- Standard deviation of the entire population
SELECT stddev_pop(median_hh_income)
FROM acs_2011_2015_stats;

-- Covariance
SELECT covar_pop(median_hh_income, pct_bachelors_higher)
FROM acs_2011_2015_stats;

-- Listing 10-6: The rank() and dense_rank() window functions

CREATE TABLE widget_companies (
    id bigserial,
    company varchar(30) NOT NULL,
    widget_output integer NOT NULL
);

INSERT INTO widget_companies (company, widget_output)
VALUES
    ('Morse Widgets', 125000),
    ('Springfield Widget Masters', 143000),
    ('Best Widgets', 196000),
    ('Acme Inc.', 133000),
    ('District Widget Inc.', 201000),
    ('Clarke Amalgamated', 620000),
    ('Stavesacre Industries', 244000),
    ('Bowers Widget Emporium', 201000);

SELECT
    company,
    widget_output,
    rank() OVER (ORDER BY widget_output DESC),
    dense_rank() OVER (ORDER BY widget_output DESC)
FROM widget_companies;

-- Listing 10-7: rank() within groups using PARTITION BY

CREATE TABLE store_sales (
    store varchar(30),
    category varchar(30) NOT NULL,
    unit_sales bigint NOT NULL,
    CONSTRAINT store_category_key PRIMARY KEY (store, category)
);

INSERT INTO store_sales (store, category, unit_sales)
VALUES
    ('Broders', 'Cereal', 598),
    ('Wallace', 'Ice Cream', 864),
    ('Broders', 'Ice Cream', 210),
    ('Cramers', 'Ice Cream', 1015),
    ('Broders', 'Beer', 344),
    ('Cramers', 'Cereal', 1744),
    ('Cramers', 'Beer', 781),
    ('Wallace', 'Cereal', 422),
    ('Cramers', 'Ground Beef', 994),
    ('Wallace', 'Beer', 211);

SELECT
    store,
    category,
    unit_sales,
    rank() OVER (PARTITION BY store ORDER BY unit_sales DESC)
FROM store_sales;

-- Listing 10-8: Create and fill 2015 FBI crime data table

CREATE TABLE fbi_crime_data_2015 (
    st varchar(20),
    city varchar(50),
    population integer,
    violent_crime integer,
    property_crime integer,
    burglary integer,
    larceny_theft integer,
    motor_vehicle_theft integer,
    CONSTRAINT st_city_key PRIMARY KEY (st, city)
);

COPY fbi_crime_data_2015
FROM 'C:\YourDirectory\fbi_crime_data_2015.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM fbi_crime_data_2015
ORDER BY population DESC;


-- Listing 10-9: Find property crime rates per thousand in cities with 500,000 or more people

SELECT
    city,
    st,
    population,
    property_crime,
    round(
        (property_crime::numeric / population) * 1000, 1
        ) AS pc_per_1000
FROM fbi_crime_data_2015
WHERE population >= 500000
ORDER BY (property_crime::numeric / population) * 1000 DESC;