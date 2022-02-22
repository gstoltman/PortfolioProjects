Select *
From PortfolioProject1..CovidDeaths
Order by 3, 4

--Select *
--From PortfolioProject1..CovidVaccinations
--Order by 3, 4

--Select the Data that we are going to be using

Select continent, Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Order by 1, 2, 3

--Looking at Total Cases vs. Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
WHERE location like '%states%'
Order by 1, 2

--Looking at Total Cases vs. Population
--Shows what percentage of population got COVID

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject1..CovidDeaths
WHERE location like '%states%'
Order by 1, 2

--What countries have the highest infection rate compared to population

Select continent, Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject1..CovidDeaths
GROUP BY continent, Location, population
Order by InfectedPercentage DESC

--Countries with the highest death count

Select Location, SUM(CAST(new_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
WHERE continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'High income', 'Low income')
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Continents with the highest death count

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers per day

Select date, SUM(new_cases) as GlobalCases, SUM(CAST(new_deaths as int)) as GlobalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
WHERE continent is not null
Group by date
Order by 1, 2

--Total global numbers

Select SUM(new_cases) as GlobalCases, SUM(CAST(new_deaths as int)) as GlobalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
WHERE continent is not null
Order by 1, 2

--Looking at Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaxCount,
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
Where dea.continent is not null
Order by 1, 2, 3

--CTE METHOD

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaxCount)
AS (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaxCount
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
Where dea.continent is not null
)

SELECT *, (RollingVaxCount/population)*100 as PercentVaxxed
From PopvsVac

--TEMP TABLE METHOD

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaxCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaxCount
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
Where dea.continent is not null

SELECT *, (RollingVaxCount/population)*100 as PercentVaxxed
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaxCount
From PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
Where dea.continent is not null

--For visualization, views 1 - 4
--1.

Create View TotalGlobalStats as 
Select SUM(new_cases) as GlobalCases, SUM(CAST(new_deaths as int)) as GlobalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
WHERE continent is not null

SELECT * FROM dbo.TotalGlobalStats

--2.

Create View TotalDeathCount as
Select Location, SUM(CAST(new_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
WHERE continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'High income', 'Low income')
Group by location

SELECT * FROM dbo.TotalDeathCount

--3.

Create View PercentInfected as
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject1..CovidDeaths
WHERE location not in ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'High income', 'Low income')
GROUP BY Location, population

SELECT * FROM dbo.PercentInfected


--4.

Create View PercentInfectedTimeline as 
Select Location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentageDate
From PortfolioProject1..CovidDeaths
WHERE location not in ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'High income', 'Low income', 'Africa', 'Asia', 'Europe', 'Oceania', 'North America', 'South America')
GROUP BY location, population, date

SELECT * FROM dbo.PercentInfectedTimeline

--5

Create View TotalDeathCountCountry as
Select Location, population, SUM(CAST(new_deaths as int)) as TotalDeathCountCountry
From PortfolioProject1..CovidDeaths
WHERE continent is not null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'High income', 'Low income')
Group by location, population

SELECT * FROM dbo.TotalDeathCountCountry