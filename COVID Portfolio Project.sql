--Where continent is not null - doesnt include NULL definitions within the column


Select * 
From PortfolioProject..comma_Covid_Deaths
Where continent is not null 
order by 3,4


--Select * 
--From PortfolioProject..Covid_Vaccinations
--order by 3,4

-- Select Data that I will be using 


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..comma_Covid_Deaths
order by 1,2


-- Looking at Total Cases vs Total Deaths:
--(So how many cases are there in certain country and how many deaths do they have for their entire cases. e.g. I have 1k people who were diagnosed and 10 people who dies whats the
-- % of people who died who had COVID). 
-- Shows likelihood of dying if you contrct COVID within your country. (Where (define_table) like '%define_what_to_be_shown_from_table%'

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercetnage
From PortfolioProject..comma_Covid_Deaths
Where location like '%slovakia%'
order by 1,2


-- Looking at Total Cases vs Population 
-- Shows what % of population got COVID 

Select Location, date, population, total_cases, (total_cases/population)*100 as Percentage_Infected
From PortfolioProject..comma_Covid_Deaths
-- Where location like '%slovakia%'
order by 1,2 


-- Countries with Highest Infection Rate Compared to Population
-- desc - gets you the highest number first
-- order by - set order of result (use desc to reverse order)
-- group by - groups data into logical sets 

Select Location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Percentage_Infected
From PortfolioProject..comma_Covid_Deaths
-- Where location like '%italy%'
 Group by Location, population
 order by Percentage_Infected desc 


 -- Showing Contries with the Highest Death Count per Population 
 -- If you want to recast table type (e.g. string to integer the command is cast(name) as (desired format) - e.g. Select Location, max(cast(total_deaths as int)) as TotalDeathCount -- recasts it into integer
 
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..comma_Covid_Deaths
Where continent is not null
-- Where location like '%italy%'
 Group by Location
 order by TotalDeathCount desc 


 -- LET'S BREAK THINGS BY CONTINENT

 -- Showing Continents with the Highest Death Count per Population 

  Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..comma_Covid_Deaths
Where continent is null
-- Where location like '%italy%'
 Group by location
 order by TotalDeathCount desc 

 -- This is the point where i want to start to visualise things (how its gona look in BI or Tableau). Drill Down Effect - capability that takes the user from a more general view of the data
 -- to a more specific one at the click of a mouse. E.g. I click on Africa and then there is all the African countries. That possible if I have layers (continent. location...).
 
 -- GLOBAL NUMBERS 

 Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..comma_Covid_Deaths
--Where location like '%slovakia%'
Where continent is not null
--Group by date
order by 1,2



-- From now on I am joining 2 tables together and I am joining them on location and date.

Select *
From PortfolioProject..comma_Covid_Deaths dea
Join PortfolioProject..comma_Covid_Vaccinations_ vac
	on dea.location = vac.location
	and dea.date = vac.date 

-- Looking at Total Population vs Vaccinations (so what is the total amount of people in the world that have been vaccinated) 
-- if i have --- , (RollingPeopleVaccinated/population)*100   I cannot use new created column to use in the next command so what i need to do is to create either CTE or TEMP table 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..comma_Covid_Deaths dea
Join PortfolioProject..comma_Covid_Vaccinations_ vac
	on dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
order by 2,3 


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..comma_Covid_Deaths dea
Join PortfolioProject..comma_Covid_Vaccinations_ vac
	on dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- TEMP TABLE 
-- DROP Table if exists #PercentPopulationVaccinated - Reccomended if I make any alterations. When you run it multiple time i dont have to go and delete the view or delete the temp table or drop time table 
-- Its on a top, its easy to maintain, it looks good...

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..comma_Covid_Deaths dea
Join PortfolioProject..comma_Covid_Vaccinations_ vac
	on dea.location = vac.location
	and dea.date = vac.date 
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercVacc
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..comma_Covid_Deaths dea
Join PortfolioProject..comma_Covid_Vaccinations_ vac
	on dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3


-- This is something i can now use for visualization later. In normal setting if I would be working I would put some of these in actuall work view tble or smth set aside so I can use them consistently
-- but I would also set them aside so that I can connect Tableau to that view. 

Select * 
from PercentPopulationVaccinated

