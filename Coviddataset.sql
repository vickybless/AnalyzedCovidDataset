use Covid_Dataset;

-- Total cases Vs total deaths with the likelyhood of dying if you contact covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS Death_percentage
FROM coviddeaths
WHERE location like '%uni%'

ORDER BY 1, 2;


-- Shows what percentage of population got covid(total cases VS population)
SELECT location, date, total_cases, population, (total_cases/population) AS population_percentage FROM coviddeaths
WHERE location like '%ab%'
ORDER BY 1,2;

-- showing countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) As highest_infectionRate, max(total_cases/population)* 100 AS PercentPoulation_infected FROM coviddeaths
GROUP BY location, total_cases, population 
ORDER BY PercentPoulation_infected DESC;

-- Showing countries with the highest death count
SELECT location, MAX(CAST(total_deaths as SIGNED INTEGER)) AS highest_deaths FROM coviddeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY highest_deaths DESC;

-- Showing continents with the highest death count
SELECT continent, MAX(CAST(total_deaths as SIGNED INTEGER)) AS highest_deaths FROM coviddeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY highest_deaths DESC;

-- Showing death count in the world By Date.
SELECT date, SUM(new_cases) AS total_case, SUM(cast(new_deaths AS SIGNED INTEGER)) AS total_deaths, SUM(cast(new_deaths AS SIGNED INTEGER))/ SUM(new_cases)* 100 AS Death_percentage
FROM coviddeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1, 2;

-- Showing death count in the world(overrall statistics)
SELECT SUM(new_cases) AS total_case, SUM(cast(new_deaths AS SIGNED INTEGER)) AS total_deaths, SUM(cast(new_deaths AS SIGNED INTEGER))/ SUM(new_cases)* 100 AS Death_percentage
FROM coviddeaths
WHERE continent is not NULL
ORDER BY 1, 2;

-- Showing Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS SIGNED INTEGER)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeople_vacinated
FROM coviddeaths dea
JOIN covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date;
-- ORDER BY 5 DESC;

-- --Further Solution on Population VS Vaccinations making use of CTE

WITH PopvsVac (continent, date, location, population, new_vaccinations, RollingPeople_vacinated) 
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS SIGNED INTEGER)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeople_vacinated
FROM coviddeaths dea
JOIN covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeople_vacinated/population) FROM PopvsVac;

-- Creating View to store date for data visualization.

CREATE VIEW PopvsVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS SIGNED INTEGER)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeople_vacinated
FROM coviddeaths dea
JOIN covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null;

SELECT * FROM PopvsVac
ORDER BY RollingPeople_vacinated DESC





