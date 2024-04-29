SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population contracted covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS MaxCases, (MAX(total_cases)/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC

-- Let's break things down by continent
SELECT location, MAX(total_deaths) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeaths DESC

SELECT continent, SUM(new_deaths) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Global numbers

SELECT /*date,*/ SUM(new_cases) AS NewCases, SUM(new_deaths) AS NewDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date

-- Looking at Total Population vs Vaccinations
SELECT dths.continent, dths.location, dths.date, dths.population, vacs.new_vaccinations
FROM PortfolioProject..CovidDeaths dths
JOIN PortfolioProject..CovidVaccinations vacs
	ON dths.location = vacs.location
	AND dths.date = vacs.date
WHERE dths.continent IS NOT NULL
ORDER BY 2,3

-- Looking at Total Population vs Vaccinations + using a window function for rolling total on new vaccinations
SELECT dths.continent, dths.location, dths.date, dths.population, vacs.new_vaccinations, 
	SUM(vacs.new_vaccinations) OVER (PARTITION BY dths.location ORDER BY dths.location, dths.date) AS RollingTotalVaccinated
FROM PortfolioProject..CovidDeaths dths
JOIN PortfolioProject..CovidVaccinations vacs
	ON dths.location = vacs.location
	AND dths.date = vacs.date
WHERE dths.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE to find the Rolling Total Vaccinated expressed as percentage of Population
WITH TotalVaccinated (continent, location, date, population, new_vaccinations, RollingTotalVaccinated) AS (
SELECT dths.continent, dths.location, dths.date, dths.population, vacs.new_vaccinations, 
	SUM(vacs.new_vaccinations) OVER (PARTITION BY dths.location ORDER BY dths.location, dths.date) AS RollingTotalVaccinated
FROM PortfolioProject..CovidDeaths dths
JOIN PortfolioProject..CovidVaccinations vacs
	ON dths.location = vacs.location
	AND dths.date = vacs.date
WHERE dths.continent IS NOT NULL
)

SELECT *, (RollingTotalVaccinated/population)*100 AS PercentageVaccinated
FROM TotalVaccinated
ORDER BY 2,3

-- Use a Temp Table to find the Rolling Total Vaccinated expressed as percentage of Population
DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated (
	continent varchar(50),
	location varchar(50),
	date date,
	population float,
	new_vaccinations float,
	RollingTotalVaccinated float
)

INSERT INTO PercentPopulationVaccinated
SELECT dths.continent, dths.location, dths.date, dths.population, vacs.new_vaccinations, 
	SUM(vacs.new_vaccinations) OVER (PARTITION BY dths.location ORDER BY dths.location, dths.date) AS RollingTotalVaccinated
FROM PortfolioProject..CovidDeaths dths
JOIN PortfolioProject..CovidVaccinations vacs
	ON dths.location = vacs.location
	AND dths.date = vacs.date
WHERE dths.continent IS NOT NULL

SELECT *, (RollingTotalVaccinated/population)*100 AS PercentageVaccinated
FROM PercentPopulationVaccinated
ORDER BY 2,3
