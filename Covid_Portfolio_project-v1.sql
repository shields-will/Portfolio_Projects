SELECT * FROM Covid_proj.covid_deaths
ORDER BY 3, 4;

-- SELECT * FROM covid_proj.vaccinations
-- ORDER BY 3, 4;

-- Select the data we're going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths;

-- Looking at total cases vs total deaths 
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Looking at total cases vs population
SELECT location, date, population, total_cases, (total_cases / population) * 100 AS case_percentage
FROM covid_deaths
-- WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases), MAX(total_cases) / population * 100 AS highest_infection_rate
FROM covid_deaths
GROUP BY 1, 2
ORDER BY 4 DESC;

-- Showing highest death count by population

SELECT location, MAX(total_deaths) AS death_count
FROM covid_deaths
GROUP BY 1
ORDER BY 2 DESC;

-- Remove grouped locations, e.g. World, High Income, Asia
-- Continent column imported as  empty string (not NULL values)

SELECT location, MAX(total_deaths) AS death_count
FROM covid_deaths
WHERE continent > ' '
GROUP BY 1
ORDER BY 2 DESC;

-- View by continent

WITH total_death_count AS
	(SELECT continent, location, MAX(total_deaths) AS death_count
	FROM covid_deaths
	WHERE continent > ' '
	GROUP BY 1, 2)
SELECT continent, SUM(death_count)
FROM total_death_count
GROUP BY 1
ORDER BY 2 DESC;

-- OR (less helpful)

SELECT location, MAX(total_deaths) AS death_count
FROM covid_deaths
WHERE continent < ' '
GROUP BY location;


-- Global Numbers
SELECT date,
	SUM(new_cases) AS totalcases,
	SUM(new_deaths) AS totaldeaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS deathrate
FROM covid_deaths
WHERE continent > ' '
GROUP BY 1
ORDER BY 1;


-- Continental Numbers
SELECT continent, date,
	SUM(new_cases) AS totalcases,
	SUM(new_deaths) AS totaldeaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS deathrate
FROM covid_deaths
WHERE continent > ' '
GROUP BY 1, 2
ORDER BY 1, 2;


-- Join with Vaccinations

SELECT * FROM covid_deaths
JOIN vaccinations
	ON covid_deaths.location = vaccinations.location
    AND covid_deaths.date = vaccinations.date;
    
    
-- Global vaccinations

SELECT covid_deaths.continent,
	covid_deaths.location,
    covid_deaths.date,
    covid_deaths.population,
    vaccinations.new_vaccinations
FROM covid_deaths
JOIN vaccinations
	ON covid_deaths.location = vaccinations.location
    AND covid_deaths.date = vaccinations.date
WHERE covid_deaths.continent > ' '
ORDER BY 2, 3;

-- Vaccinations per country, 

SELECT covid_deaths.continent,
	covid_deaths.location,
	covid_deaths.date,
    covid_deaths.population,
    vaccinations.new_vaccinations,
    SUM(vaccinations.new_vaccinations)
		OVER (PARTITION BY covid_deaths.location
			  ORDER BY covid_deaths.location, covid_deaths.date) 
		AS rolling_vaccinations
FROM covid_deaths
JOIN vaccinations
	ON covid_deaths.location = vaccinations.location
    AND covid_deaths.date = vaccinations.date
WHERE covid_deaths.continent > ' '
ORDER BY 2, 3;

-- Creating a view to store data for future visualizations

CREATE VIEW Global_Death_rates AS
SELECT date,
	SUM(new_cases) AS totalcases,
	SUM(new_deaths) AS totaldeaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS deathrate
FROM covid_deaths
WHERE continent > ' '
GROUP BY 1
ORDER BY 1;

CREATE VIEW Vaccinations_per_Country AS
SELECT covid_deaths.continent,
	covid_deaths.location,
	covid_deaths.date,
    covid_deaths.population,
    vaccinations.new_vaccinations,
    SUM(vaccinations.new_vaccinations)
		OVER (PARTITION BY covid_deaths.location
			  ORDER BY covid_deaths.location, covid_deaths.date) 
		AS rolling_vaccinations
FROM covid_deaths
JOIN vaccinations
	ON covid_deaths.location = vaccinations.location
    AND covid_deaths.date = vaccinations.date
WHERE covid_deaths.continent > ' '
ORDER BY 2, 3;

CREATE VIEW global_vaccinations AS
SELECT covid_deaths.continent,
	covid_deaths.location,
    covid_deaths.date,
    covid_deaths.population,
    vaccinations.new_vaccinations
FROM covid_deaths
JOIN vaccinations
	ON covid_deaths.location = vaccinations.location
    AND covid_deaths.date = vaccinations.date
WHERE covid_deaths.continent > ' '
ORDER BY 2, 3;