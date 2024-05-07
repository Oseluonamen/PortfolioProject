
select * 
from PortfolioProject..coviddeaths
where continent is not null
order by continent, total_deaths desc



select Location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1, 2


--Shows the likelihood of dying if you contract covid in Nigeria
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
where location like '%Nigeria%'
order by 1, 2



---Looking  at Total cases vs population
---Shows what percentage of population got covid
select Location, date,population,total_cases, (total_cases/population)*100 as deathpercentage
from PortfolioProject..coviddeaths
where location like '%Nigeria%'
order by 1, 2


--Looking at countries with higest infection Rate compared to Population
select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..coviddeaths
group by  Location, population
order by PercentagePopulationInfected desc

--Showing countries with highest death per population
select location, max(total_deaths) as totaldeathcount
from PortfolioProject..coviddeaths
group by  Location
order by totaldeathcount desc


--showing with the contient with the highest death count
select continent, max(total_deaths) as totaldeathcount
from PortfolioProject..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc

---Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)* 100 as deathpercentage
from PortfolioProject..coviddeaths
where continent is not null
order by 1, 2


--Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


---use CTE

with Popvsvac (continent, location,date,population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select*, (RollingPeopleVaccinated/population)*100
from Popvsvac



---Temp Table

drop table if exists #Percentagepopulationvaccinated

create Table #Percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #Percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #Percentagepopulationvaccinated



---creating view to store data for later visualizations

create view Percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from Percentpopulationvaccinated