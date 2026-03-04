CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;


-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
        consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;

-- General & Comparative Analysis
-- Total emission per country for the most recent year
SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country
ORDER BY total_emission DESC;

-- 2️ Top 5 countries by GDP (most recent year)
select Country,Value as GDP from gdp_3
where year = (select max(Year) from gdp_3)
order by GDP desc
limit 5;
-- 3️ Compare energy production and consumption by country & year
SELECT 
    p.country,
    p.year,
    SUM(p.production) AS total_production,
    SUM(c.consumption) AS total_consumption
FROM production p
JOIN consumption c
ON p.country = c.country AND p.year = c.year
GROUP BY p.country, p.year;

-- 4 Energy types contributing most to emissions
select energy_type,sum(emission) as Total_Emmision
from emission_3 group by energy_type
order by  Total_Emmision desc;

-- Trend Analysis Over Time

--  5 Global emissions year over year
select Year,sum(emission) as Global_Emisssion from emission_3
group by year
order by Year;

-- 6 GDP trend for each country
select Country,Value as GDP from gdp_3
order by Country,Year;

-- 7 Impact of population growth on emissions
SELECT 
    e.country,
    e.year,
    SUM(e.emission) AS total_emission,
    p.Value AS population
FROM emission_3 e
JOIN population p
ON e.country = p.countries AND e.year = p.year
GROUP BY e.country, e.year, p.Value;

-- 8 Energy consumption trend for major economies
select Country,Year,sum(Consumption) as Total_Consumption from Consumption
group by Country,year
order by Country,Year;

-- 9 Average yearly change in per-capita emissions
SELECT country, AVG(per_capita_emission) AS avg_per_capita_emission
FROM emission_3
GROUP BY country;

--  10 Emission-to-GDP ratio 
SELECT 
    e.country,
    e.year,
    SUM(e.emission) / g.Value AS emission_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g
ON e.country = g.Country AND e.year = g.year
GROUP BY e.country, e.year, g.Value;

--  11 Energy consumption per capita (last 10 years)
SELECT 
    c.country,
    c.year,
    SUM(c.consumption) / p.Value AS consumption_per_capita
FROM consumption c
JOIN population p
ON c.country = p.countries AND c.year = p.year
WHERE c.year >= (SELECT MAX(year) - 10 FROM consumption)
GROUP BY c.country, c.year, p.Value;

-- 12 Energy production per capita
SELECT 
    pr.country,
    pr.year,
    SUM(pr.production) / p.Value AS production_per_capita
FROM production pr
JOIN population p
ON pr.country = p.countries AND pr.year = p.year
GROUP BY pr.country, pr.year, p.Value;

--  13 Highest energy consumption relative to GDP
SELECT 
    c.country,
    c.year,
    SUM(c.consumption) / g.Value AS consumption_gdp_ratio
FROM consumption c
JOIN gdp_3 g
ON c.country = g.Country AND c.year = g.year
GROUP BY c.country, c.year, g.Value
ORDER BY consumption_gdp_ratio DESC;

--  14 Correlation between GDP growth & energy production growth
SELECT 
    g.Country,
    g.year,
    g.Value AS GDP,
    SUM(p.production) AS production
FROM gdp_3 g
JOIN production p
ON g.Country = p.country AND g.year = p.year
GROUP BY g.Country, g.year, g.Value;

-- Global Comparisons
-- 15 Top 10 countries by population & emissionsSELECT 
   SELECT 
    p.countries,
    p.Value AS population,
    SUM(e.emission) AS total_emission
FROM population p
JOIN emission_3 e
ON p.countries = e.country
WHERE p.year = (
    SELECT MAX(year)
    FROM population
    WHERE year IN (SELECT DISTINCT year FROM emission_3)
)
AND e.year = p.year
GROUP BY p.countries, p.Value
ORDER BY population DESC
LIMIT 10;


--  16 Countries that reduced per-capita emissions most (last decade)
SELECT country,
       MAX(per_capita_emission) - MIN(per_capita_emission) AS reduction
FROM emission_3
WHERE year >= (SELECT MAX(year) - 10 FROM emission_3)
GROUP BY country
ORDER BY reduction DESC;

--  17 Global share (%) of emissions by country
SELECT 
    country,
    SUM(emission) * 100.0 / (SELECT SUM(emission) FROM emission_3) AS emission_share_percent
FROM emission_3
GROUP BY country
ORDER BY emission_share_percent DESC;

--  18 Global average GDP, emissions & population by year
SELECT 
    e.year,
    AVG(g.Value) AS avg_gdp,
    AVG(e.emission) AS avg_emission,
    AVG(p.Value) AS avg_population
FROM emission_3 e
JOIN gdp_3 g ON e.country = g.Country AND e.year = g.year
JOIN population p ON e.country = p.countries AND e.year = p.year
GROUP BY e.year
ORDER BY e.year;





