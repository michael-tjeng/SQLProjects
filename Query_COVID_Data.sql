SELECT *
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidProject..CovidVaccinations
--ORDER BY 3,4

-- Select data that we're going to be using
-- added IS NOT NULL statement to remove redundant / incomplete data
-- continent IS NOT NULL is to filter out data that is categorised as
-- entire continents. We only want to view by country.
SELECT location, date, total_cases, new_cases, total_cases, population
FROM CovidProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 1,2

-- Look for Total Cases VS Total Deaths
-- In other words, this shows the % chance of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE LOCATION like '%states%' AND TOTAL_CASES IS NOT NULL AND total_deaths IS NOT NULL AND continent IS NOT NULL
ORDER BY location, date

-- Looking for the Total Cases VS Population
-- In other words, this shows the % of population that contracted covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentageOfPopulationInfected
FROM CovidProject..CovidDeaths
WHERE LOCATION like '%states%' AND TOTAL_CASES IS NOT NULL AND total_deaths IS NOT NULL AND continent IS NOT NULL
ORDER BY location, date

-- Looking for countries that have the highest infection rates per population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
FROM CovidProject..CovidDeaths
WHERE population IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected DESC

-- Showing countries with Highest Count per population
-- Note that Total_deaths column in the raw dataset is nvarchar, therefore
-- it has to be converted into int using CAST function
SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE population IS NOT NULL AND continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC

-- View by Total Deaths by Continent
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE population IS NOT NULL AND continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global figures
-- new_deaths column is an nvarchar, therefore used CAST to convert
-- it into int
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE total_cases IS NOT NULL AND total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY date
ORDER BY date


--Looking at Total Population VS Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths AS dea
JOIN CovidProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND population IS NOT NULL
ORDER BY 2,3

-- Use CTE
With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths AS dea
JOIN CovidProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND population IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

-- Use TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths AS dea
JOIN CovidProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND population IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for visualisation purpose
CREATE VIEW PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths AS dea
JOIN CovidProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated