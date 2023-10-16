-------------------------------------------------
-- MDM5053 Assessment 2: COVID-19 SQL Analysis --
-------------------------------------------------

-- 0. View COVID-19 Deaths and Vaccinations Tables.
-- To show all the information regarding deaths and vaccinations for COVID-19 in Malaysia.
-- Use the * symbol to select all the columns from the tables.
SELECT 
    *
FROM
    covid19a2.coviddeaths;

SELECT 
    *
FROM
    covid19a2.covidvaccinations;


-- 1. Total Cases, Total Deaths, & Death Rate(%) per Total Cases by Date.
-- Show the  total deaths and death rates of total cases in Malaysia.
-- Use AS command is used to rename calculation column with an alias.
-- Use ORDER BY to sort the values of a column using ASC (default) or DESC.
SELECT 
    location,
    date,
    population,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS death_rate
FROM
    covid19a2.coviddeaths
ORDER BY date DESC;


-- 2. Infection Rate(%) per Population by Date.
-- Show the percentage of population contracting Covid-19 in Malaysia.
-- Use AS command is used to rename calculation column with an alias.
-- Use ORDER BY to sort the values of a column using ASC (default) or DESC.
SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS infection_rate
FROM
    covid19a2.coviddeaths
-- GROUP BY population
ORDER BY date DESC;


-- 3. Overall Infection Rate per Population & Death Rate per Total Cases.
-- Show the average deaths, overall percentage of the infection rate and death rate of the 
-- population and total cases, respectively, in Malaysia.
-- Use aggregate functions to calculate the maximum and average values of a column.
-- Use AS command is used to rename calculation column with an alias.
SELECT 
    location,
    population,
    MAX(total_cases) AS total_cases,
    MAX(total_deaths) AS total_deaths,
    AVG(total_deaths) AS avg_deaths,
    MAX((total_cases / population)) * 100 AS infection_rate,
    MAX((total_deaths / total_cases)) * 100 AS death_rate
FROM
    covid19a2.coviddeaths;
-- GROUP BY population;


-- 4. Overall Death Count & Death Rate per Population.
-- Show the overall death count and death rate per population and total cases in Malaysia.
-- Use aggregate functions to calculate the maximum and average values of a column.
SELECT 
    location,
    population,
    MAX(total_deaths) AS total_deaths,
    (MAX(total_deaths) / population) * 100 AS death_rate_by_population
FROM
    covid19a2.coviddeaths;
-- GROUP BY population;


--  5. Overall Vaccinated & Fully Vaccinated Rate(%) per Population.
-- Show the overall vaccinated and fully vaccinated rates per population in Malaysia.
-- Use aggregate functions to calculate the maximum and average values of a column.
-- Use JOIN & ON functions to join the two tables on the location.
SELECT 
    d.location,
    d.population,
    MAX(v.people_vaccinated) AS people_vaccinated,
    MAX(v.people_fully_vaccinated) AS people_fully_vaccinated,
    MAX(v.people_vaccinated) / d.population * 100 AS vaccinated_rate,
    MAX(v.people_fully_vaccinated) / d.population * 100 AS fully_vaccinated_rate
FROM
    covid19a2.coviddeaths AS d
        JOIN
    covid19a2.covidvaccinations AS v ON d.location = v.location;
-- GROUP BY population;


-- 6. Rolling Vaccinations by Date.
-- Show the total population V.S. number of vaccinations given to Malasysians. 
-- Use aggregate functions to calculate the maximum and average values of a column.
-- Partition by location & date to ensure that once the rolling sum of new vaccinations for a location stops, 
-- the rolling sum starts for the next location (in this case, we only focus on Malaysia, still good coding practice).
-- Use JOIN & ON functions to join the two tables on the location and date.
-- Use ORDER BY to sort the values of a column using ASC (default) or DESC.

-- SELECT d.location, d.date, d.population, v.new_vaccinations, 
-- SUM(v.new_vaccinations) OVER (PARTITION BY d.location
-- ORDER BY d.location, d.date) AS rolling_vaccinations
-- FROM covid19a2.coviddeaths AS d
-- JOIN covid19a2.covidvaccinations AS v
-- ON d.location = v.location 
-- AND d.date = v.date
-- ORDER BY d.date DESC;


-- 6. Rolling Vaccinations & Percentage of Vaccinated Population.
-- Show the total population V.S. number of vaccinations and percentage of the 
-- vaccinated population by date in Malaysia.
-- Use Common Table Expressions (CTE) as a reference name for a SELECT statement,
-- which can be used with a subsequent SELECT statement.
-- Use CTE with the SQL code as above.
-- Use ORDER BY to sort the values of a column using ASC (default) or DESC.
WITH vaccination_per_population (location, date, population, new_vaccinations, rolling_vaccinations) 
AS 
(
SELECT d.location, d.date, d.population, v.new_vaccinations, 
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location
		ORDER BY d.location, d.date) AS rolling_vaccinations
FROM covid19a2.coviddeaths AS d
JOIN covid19a2.covidvaccinations AS v
	ON d.location = v.location 
	AND d.date = v.date
)
SELECT *, (rolling_vaccinations/population) * 100 AS vaccinated_per_population
FROM vaccination_per_population
ORDER BY date DESC;
