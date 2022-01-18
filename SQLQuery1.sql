SELECT * 
from Portfolio_Project..Covid_Deaths$
Where continent is not null 
order by 3,4


--SELECT * 
--from Portfolio_Project..Covid_vaccinated$
--order by 3,4


-- select data that we are going to be use

SELECT location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..Covid_Deaths$
Where continent is not null 
order by 1,2


--looking at total cases vs Total death
-- shows likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from Portfolio_Project..Covid_Deaths$
Where continent is not null 
and location like '%ind%'
order by 1,2


-- looking at total cases vs population 
-- shows what percentage of population got covid 

SELECT location, date, population, total_cases, (total_cases/population)*100 as Perccent_population_Infected
from Portfolio_Project..Covid_Deaths$
Where continent is not null 
--WHERE location like '%ind%'
order by 1,2


-- looking at country at highest infection rate compred to population 

SELECT location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Perccent_population_Infected
from Portfolio_Project..Covid_Deaths$
Where continent is not null 
--WHERE location like '%ind%'
GROUP by location, population 
order by Perccent_population_Infected desc


-- Showing countries with highest Death count per population 

SELECT location, max(cast (total_Deaths as int)) as TotalDeathCount
from Portfolio_Project..Covid_Deaths$
Where continent is not null 
--WHERE location like '%ind%'
GROUP by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTTINETS 

SELECT continent, max(cast (total_Deaths as int)) as TotalDeathCount
from Portfolio_Project..Covid_Deaths$
Where continent is not null 
--WHERE location like '%ind%'
GROUP by continent
order by TotalDeathCount desc


-- showing continents with highest death count per population

SELECT continent, max(cast (total_Deaths as int)) as TotalDeathCount
from Portfolio_Project..Covid_Deaths$
Where continent is not null 
--WHERE location like '%ind%'
GROUP by continent
order by TotalDeathCount desc


-- globle numbers

SELECT   sum(new_cases )as TotalCases, sum(cast(new_deaths as int ))as TotalDeath , sum(cast(new_deaths as int ))/sum(new_cases)*100 as Death_percentage
from Portfolio_Project..Covid_Deaths$
Where continent is not null 
--and location like '%ind%'
--group by date 
order by 1,2


-- looking at total population  vs vaccination 

select dea.continent,dea.location, dea.date , dea.population , vac.new_vaccinations,
sum(CONVERT(BIGint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date ) as Rolling_People_Vaccinating,
--(Rolling_People_Vaccinating/dea.population)*100
from Portfolio_Project..Covid_Deaths$ dea 
join Portfolio_Project..Covid_vaccinated$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE

with POPvsVAC (continent,location,date ,population , new_vaccinations,Rolling_People_Vaccinating)
as 
(
select dea.continent,dea.location, dea.date , dea.population , vac.new_vaccinations,
sum(CONVERT(BIGint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date ) as Rolling_People_Vaccinating
from Portfolio_Project..Covid_Deaths$ dea 
join Portfolio_Project..Covid_vaccinated$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (Rolling_People_Vaccinating/population)*100
from POPvsVAC





-- Temp Table 
DROP TABLE if exists #Percentpopulation
create table #Percentpopulation
(continent nvarchar(255),
location nvarchar(255),
date  datetime ,
population numeric,
new_vaccination numeric,
Rolling_People_Vaccinating numeric
)
insert into #Percentpopulation
select dea.continent,dea.location, dea.date , dea.population , vac.new_vaccinations,
sum(CONVERT(BIGint,vac.new_vaccinations)) OVER 
(partition by dea.location order by dea.location , dea.date ) as Rolling_People_Vaccinating
from Portfolio_Project..Covid_Deaths$ dea 
join Portfolio_Project..Covid_vaccinated$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT * , (Rolling_People_Vaccinating/population)*100
from #Percentpopulation



-- creating view to store data for later visulization 

	create view Percentpopulation as 
	select dea.continent,dea.location, dea.date , dea.population , vac.new_vaccinations,
	sum(CONVERT(BIGint,vac.new_vaccinations)) OVER 
	(partition by dea.location order by dea.location , dea.date ) as Rolling_People_Vaccinating
	from Portfolio_Project..Covid_Deaths$ dea 
	join Portfolio_Project..Covid_vaccinated$ vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3










