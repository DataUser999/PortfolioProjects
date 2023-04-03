Select *
From New_Portfolio_Project_1..CovidDeaths_1
Where continent is not null
order by 3,4

--Select *
--From New_Portfolio_Project_1..CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From New_Portfolio_Project_1..CovidDeaths_1
Where continent is not null
order by 1,2

Select * 
From New_Portfolio_Project_1..CovidVaccinations

order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of Dying if you contract Covid in your Country
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage 
From New_Portfolio_Project_1..CovidDeaths_1
Where Location like '%states%'
and continent is not null
order by 1,2


--Looking at Total Ceses vs  Population
--Shows what percentage of the Population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From New_Portfolio_Project_1..CovidDeaths_1
Where Location like '%states%'
order by 1,2


-- Looking at Counteries with Highest infection Rate comlared to Population
--Looking at Total Ceses vs  Population
--Shows what percentage of the Population got Covid
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
From New_Portfolio_Project_1..CovidDeaths_1
--Where Location like '%states%'--
Group by Location, population

order by PercentPopulationInfected desc

-- Showing Counteries with the Highest Death Count per Population


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From New_Portfolio_Project_1..CovidDeaths_1
--Where Location like '%states%'--
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Showing Counteries with the Highest Death Count per Population
-- Breaking it down by Continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From New_Portfolio_Project_1..CovidDeaths_1
--Where Location like '%states%'--
Where continent is not null
Group by continent 
order by TotalDeathCount desc


--Filtering by null for Country

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From New_Portfolio_Project_1..CovidDeaths_1
--Where Location like '%states%'--
Where continent is null
Group by location 
order by TotalDeathCount desc


-- Showing the Continents with the highest Death Count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From New_Portfolio_Project_1..CovidDeaths_1
--Where Location like '%states%'--
Where continent is not null
Group by continent 
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From New_Portfolio_Project_1..CovidDeaths_1
--Where Location like '%states%'
Where continent is not null
Group by Date
order by 1,2

-- ADD TITLES to the columns

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From New_Portfolio_Project_1..CovidDeaths_1
--Where Location like '%states%'
Where continent is not null
Group by Date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From New_Portfolio_Project_1..CovidDeaths_1
--Where Location like '%states%'
Where continent is not null
--Group by Date
order by 1,2

--Covid Vaccinations
--Looking at Total Population vs Vaccination

Select *
From New_Portfolio_Project_1..CovidDeaths_1 dea
Join New_Portfolio_Project_1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From New_Portfolio_Project_1..CovidDeaths_1 dea
Join New_Portfolio_Project_1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	order by 2,3


	
--	(RollingPeopleVaccinated/population)* 100


--USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
From New_Portfolio_Project_1..CovidDeaths_1 dea
Join New_Portfolio_Project_1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Where dea.continent is not null
)
--order by 2,3

select *
From PopvsVac


--ADDING THE NUMBERS

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
From New_Portfolio_Project_1..CovidDeaths_1 dea
Join New_Portfolio_Project_1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Where dea.continent is not null
)
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
--Create Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
From New_Portfolio_Project_1..CovidDeaths_1 dea
Join New_Portfolio_Project_1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
From New_Portfolio_Project_1..CovidDeaths_1 dea
Join New_Portfolio_Project_1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated