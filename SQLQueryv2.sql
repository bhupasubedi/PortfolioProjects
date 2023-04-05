SELECT *
FROM CovidDeaths
Where continent is not null
order by  3,4 

--SELECT *
--FROM CovidVaccinations
--order by  3,4 

## select data we are going to use.

Select location, date, total_cases, new_cases, total_cases, population
from CovidDeaths
order by  1,2 

## Looking at Total Cases VS Total Deaths
shows likelyhood of dying if you get covid in The United States

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as Deathpercentage
from CovidDeaths
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as Deathpercentage
from CovidDeaths 
where location like '%states%'
order by 1,2


-- Looking at Total Cases VS Population
-- Shows what pertcentage of popluation got covid

Select location, date, population, total_cases, (total_cases/population) *100 as Percentageofinfected
from CovidDeaths 
where location like '%states%'
order by 1,2

-- Looking at countries with Highest infection Rate compared to population 

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population) *100 as Percentageofinfected
from CovidDeaths 
--where location like '%states%'
Where continent is not null
Group by location, population
order by Percentageofinfected desc

-- showing countries with Highest Death Count per Population 

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

 -- Break things downn by continent
 -- showing contient with highest death counts

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

select location, MAX(cast(total_Deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

-- Global Numbers




Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

## total cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Looking at Total Population VS Vaccinations

Select *
from CovidDeaths Dea
Join CovidVaccinations Vac
	on dea.location = vac.location
	and Dea.date = Vac.date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths Dea
Join CovidVaccinations Vac
	on dea.location = vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM((vac.new_vaccinations as int)) OVER (Partition by dea.location)
from CovidDeaths Dea
Join CovidVaccinations Vac
	on dea.location = vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
Order by 2,3


## does the same thing as above

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeopelvaccinated
--, (Rollingpeopelvaccinated/population) *100
from CovidDeaths Dea
Join CovidVaccinations Vac
	on dea.location = vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE

WITH PopvsVac (contient, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeopelvaccinated
--, (Rollingpeopelvaccinated/population) *100
from CovidDeaths Dea
Join CovidVaccinations Vac
	on dea.location = vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
-- Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac

-- Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(DECIMAL(18,2), vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


Select *, (RollingPeopleVaccinated/Population)*100

From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(DECIMAL(18,2), vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


Select *
from PercentPopulationVaccinated