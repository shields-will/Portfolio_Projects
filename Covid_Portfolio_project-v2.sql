SELECT * FROM covid_deaths LIMIT 25;

SELECT * FROM vaccinations LIMIT 25;

-- Cases per Country by date
SELECT location, date, new_cases, new_cases_smoothed
FROM covid_deaths
WHERE continent > ' '
ORDER BY 1, 2;

-- Deaths per Country by Date
SELECT location, date, new_deaths, new_deaths_smoothed
FROM covid_deaths
WHERE continent > ' '
ORDER BY 1, 2 ;

-- Hospitalizations by Date
-- Data for some countries, including United States, begins later
SELECT location, date, hosp_patients
FROM covid_deaths
WHERE continent > ' '
ORDER BY 1, 2;

-- tests by Date
SELECT dea.location, dea.date, vac.new_tests, vac.new_tests_smoothed
FROM covid_deaths AS dea
JOIN vaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent > ' ';

-- All together

SELECT dea.location, dea.date, dea.new_cases, dea.new_cases_smoothed, dea.new_deaths, dea.new_deaths_smoothed, dea.hosp_patients, vac.new_tests, vac.new_tests_smoothed
FROM covid_deaths AS dea
JOIN vaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent > ' '
ORDER BY 1, 2;


-- VIEW of cases, deaths, hospitalizations, tests
DROP VIEW IF EXISTS main_measures;
CREATE VIEW main_measures AS
SELECT dea.location, dea.date, dea.new_cases, dea.new_cases_smoothed, dea.new_deaths, dea.new_deaths_smoothed, dea.hosp_patients, vac.new_tests, vac.new_tests_smoothed
FROM covid_deaths AS dea
JOIN vaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent > ' '
ORDER BY 1, 2;

