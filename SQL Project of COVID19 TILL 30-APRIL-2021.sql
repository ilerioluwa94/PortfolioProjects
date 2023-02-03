-- EXPLORATORY ANALYSIS ON COVID DATA BY DEATH COUNT PER POPULATION, DEATH RATE PER COUNTRY LOCATION,
-- COUNT OF VACCINATED PEOPLE PER POPULATION. VIEWS WERE INTRODUCED TO USED IN VISUALIZATION ON TABLEAU.
-- CTE WAS USED IN ORDER TO PERFORM CALCULATION ON A NEW COLUMN CREATED IN ONE OF THE QUERIES.
Use Portfolio_Project;

select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
order by 1,2;

Select *
from Portfolio_Project..CovidDeaths
where continent is not null -- filters out world and international rows
order by 3,4

-- Total Cases vs Total Deaths
-- Estimated Death rate if tested positive

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where location like '%Nigeri%'
order by 1,2


-- Exploring Total Cases vs Population
-- Population percentage who got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentageInfected
from Portfolio_Project..CovidDeaths
--where location like '%Nigeri%'
order by 1,2

-- Countries with the Highest Infection Rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PopulationPercentageInfected
from Portfolio_Project..CovidDeaths
--where location like '%Nigeri%'
group by Location, Population
order by PopulationPercentageInfected desc

-- Countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as DeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
group by location
order by DeathCount desc

-- Continent with Highest Death Count
select continent, MAX(CAST(total_deaths as int)) as DeathCount
from Portfolio_Project..CovidDeaths
where continent is not null and location not in ('World','International')
group by continent
order by DeathCount desc

-- GLOBAL NUMBER
Select Sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
(SUM(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
-- where location like '%Nigeri%'
where continent is not null
-- group by date
order by 1,2

-- Joining Vaccination and Death Table
-- Total Population Vs Vaccination

select dea.continent, vac.location, vac.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations))over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE for Total_Vaccination column calculation
WITH PopVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as 
(select dea.continent, vac.location, vac.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)
--order by 2,3)
select *, (RollingPeopleVaccinated/population)*100 as PopulationVaccinatedrate
from PopVac

-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, vac.location, vac.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PopulationVaccinatedratefrom
from #PercentPopulationVaccinated

-- Creating View to store data for later visualization

DROP VIEW IF EXISTS Global_deathrate
create view Global_deathrate as 
Select Sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
(SUM(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
-- where location like '%Nigeri%'
where continent is not null

Use Portfolio_project
Drop View if exists PercentPopulationVaccinated

Create view PercentPopulationVaccinated as
select dea.continent, vac.location, vac.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from PercentPopulationVaccinated