

select *
From [Portfolio Project]..covidDeaths
Where continent is not null
order by 3,4

--select *
--From [Portfolio Project]..covidVacanations
--order by 3,4
select location,date,total_cases,new_cases,total_deaths,population
From [Portfolio Project]..covidDeaths 
Where continent is not null
order by 1,2


-- Looking at Total cases vs Total Deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathsPercentage
From [Portfolio Project]..covidDeaths
Where location like '%india%'
and continent is not null
order by 1,2


--Looking at the Total cases vs population
--shows  what percentage of population got Covid


select location,date,population,total_cases,(total_cases/population)*100 as DeathsPercentage
From [Portfolio Project]..covidDeaths
--Where location like '%india%'
order by 1,2


select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..covidDeaths
--Where location like '%india%'
order by 1,2


-- looking at countries with highest infection rate compared to population 

select location,population,MAX (total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..covidDeaths
--Where location like '%india%'
Group by  location,population
order by PercentPopulationInfected desc

--Showing Countries with highest death count per population

select location,MAX(cast(total_deaths as int)) as TotaldDeathCount
From [Portfolio Project]..covidDeaths
--Where location like '%india%'
Where continent is not null
Group by  location
order by TotaldDeathCount desc

--Let's break things down by continent




--Showing continents with the highest death counts

select continent,MAX(cast(total_deaths as int)) as TotaldDeathCount
From [Portfolio Project]..covidDeaths
--Where location like '%india%'
Where continent is not null
Group by  continent
order by TotaldDeathCount desc


--Global numbers

select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
From [Portfolio Project]..covidDeaths
--Where location like '%india%'
Where continent is not null
--Group By date
order by 1,2


--looking at total population vs vaccinations

select dea.continent , dea.location ,dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..covidVacanations  vac
     On dea.location = vac.location  
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

	 --USE CTE

With PopvsVac (continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent , dea.location ,dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..covidVacanations  vac
     On dea.location = vac.location  
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
From popvsVac




-- USE of Temp table

DROP table if exists #PopulationVaccinated
Create Table #PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinagted numeric
)

Insert into #PopulationVaccinated
select dea.continent , dea.location ,dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..covidVacanations  vac
     On dea.location = vac.location  
	 and dea.date = vac.date
	-- where dea.continent is not null
	 --order by 2,3

select*,(RollingPeopleVaccinagted/population)*100
From #PopulationVaccinated

--Creating view to store daya for visualization


Create View VacPopulation as
select dea.continent , dea.location ,dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..covidVacanations  vac
     On dea.location = vac.location  
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From VacPopulation