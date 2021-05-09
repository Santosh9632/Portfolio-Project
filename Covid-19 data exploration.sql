--select *
--from ProjectPortfolio..covid_death_data$
--where continent is not null
--order by 3,4

--select *
--from ProjectPortfolio..covid_vaccination_data$
--order by 3,4

--Looking for Total Cases vs Total Deaths
-- Likelyhood of dying if you contract covid-19
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectPortfolio..covid_death_data$
where location like '%India%'
order by 1,2

--Looking  at total Case vs Population
select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulation
from ProjectPortfolio..covid_death_data$
-- where location like '%India%'
order by 1,2

-- Country whith highest infection rate compared to population

select Location, MAX(total_cases) as Highest_infection_count, population, MAX((total_cases/population))*100 as Percent_population_infected
from ProjectPortfolio..covid_death_data$
-- where location like '%India%'
Group by Location, population
order by Percent_population_infected desc

-- Deaths by countries

select Location, MAX(cast(total_deaths as int)) as Total_Death_count
from ProjectPortfolio..covid_death_data$
where continent is not null
Group by Location
order by Total_Death_count desc

-- Showing continents with highest deaths

select location, MAX(cast(total_deaths as int)) as Total_Death_count
from ProjectPortfolio..covid_death_data$
where continent is null
Group by location
order by Total_Death_count desc

-- Global numbers

select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from ProjectPortfolio..covid_death_data$
where continent is not null
--group by date
order by 1,2

select * 
from ProjectPortfolio..covid_death_data$ dea
join ProjectPortfolio..covid_vaccination_data$ vac
	on dea.location = vac.location
	and dea.date=vac.date

--Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vaccination
from ProjectPortfolio..covid_death_data$ dea
join ProjectPortfolio..covid_vaccination_data$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_vaccination)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vaccination
from ProjectPortfolio..covid_death_data$ dea
join ProjectPortfolio..covid_vaccination_data$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
-- er by 2,3
)
Select *, (Rolling_vaccination/population)*100
from PopvsVac

--Temp Table


with PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_vaccination)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vaccination
from ProjectPortfolio..covid_death_data$ dea
join ProjectPortfolio..covid_vaccination_data$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
-- er by 2,3
)
Select *, (Rolling_vaccination/population)*100
from PopvsVac



Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccination numeric,
Rolling_vaccination numeric
)


Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vaccination
from ProjectPortfolio..covid_death_data$ dea
join ProjectPortfolio..covid_vaccination_data$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
-- order by 2,3


Select *, (Rolling_vaccination/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visulizations

CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vaccination
from ProjectPortfolio..covid_death_data$ dea
join ProjectPortfolio..covid_vaccination_data$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
-- order by 2,3