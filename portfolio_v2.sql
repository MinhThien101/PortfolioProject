
--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percented
FROM CovidDeaths
ORDER BY 1,2

--Looking at the Total Casese vs Population
--Shows what percented of population got Covid
SELECT location, MAX(total_cases) as total_infeted, population
FROM CovidDeaths
GROUP BY location, population
ORDER BY 1,2

--Looking at Countries with Highest imfection rate compared Population

SELECT location, population, MAX(total_cases) as highest_imfection_count, MAX((total_cases/population)*100) as percen_population_imfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY percen_population_imfected DESC

--Showing Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC

--Showing Continent total death count
SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC

--Showing Global Cases

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percented
FROM CovidDeaths
WHERE continent is not null

--Looking at Total Population vs Vaccinations

With PopvsVac (continent, location, date, population, new_vaccinations, rooling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.date) as rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT location, Max(rolling_people_vaccinated), 
FROM PopvsVac
Group by location

--Temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rooling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.date) as rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (rooling_people_vaccinated/population)*100
From #PercentPopulationVaccinated

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.date) as rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select *
From PercentPopulationVaccinated