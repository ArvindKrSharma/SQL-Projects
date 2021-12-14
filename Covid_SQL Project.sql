--Select *
--from ProjectCovid..Deaths$
--Select *
--from ProjectCovid..Vaccinations$
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from ProjectCovid..Deaths$
where location='India' and continent is not null
order by 1,2

--looking at the total case vs population
Select location, date, total_cases, total_deaths,population, (total_cases/population)*100 as CasePercentage
from ProjectCovid..Deaths$
where location='India' and continent is not null
order by 1,2

-- looking for countries having hogh infection rates
Select location, population, max(total_cases) as Highestinfectioncount,max((total_cases/population))*100 as Percentpopulationinfected
from ProjectCovid..Deaths$
where continent is not null
group by location, population
order by Percentpopulationinfected desc

-- countries with hightest death count per population
Select location, population, max(cast(total_deaths as int)) as Highestdeathcount,max((cast(total_deaths as int)/population))*100 as Percentpopulationdeath
from ProjectCovid..Deaths$
where continent is not null
group by location, population
order by Highestdeathcount desc

-- By continent
Select location, max(cast(total_deaths as int)) as Highestdeathcount
from ProjectCovid..Deaths$
where continent is null
group by location
order by Highestdeathcount desc

-- continent with highest death count 
Select continent, max(cast(total_deaths as int)) as Highestdeathcount
from ProjectCovid..Deaths$
where continent is not null
group by continent
order by Highestdeathcount desc


-- global numbers
Select  sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProjectCovid..Deaths$
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from dbo.Deaths$ dea
join dbo.Vaccinations$ vac on dea.location=vac.location and dea.date=vac.date
order by 2,3	

--CTE
with popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from dbo.Deaths$ dea
join dbo.Vaccinations$ vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)

select *
From popvsvac

-- temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from dbo.Deaths$ dea
join dbo.Vaccinations$ vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *
from #percentpopulationvaccinated

--create view forlater visualization
create view percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from dbo.Deaths$ dea
join dbo.Vaccinations$ vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *
from percentpopulationvaccinated