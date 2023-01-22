USE portfolioproject;

-- Data Exploration

SELECT * FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * FROM covidvaccinations
ORDER BY 3,4;


-- SELECT DATA THAT GOING TO BE USE

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


SELECT location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases)*100 , 1) AS deathPercantage
FROM coviddeaths
WHERE location LIKE '%states%' and continent IS NOT NULL
ORDER BY 1,2;


-- Looking at Total Cases vs Population

SELECT location, date, total_cases, population, ROUND((total_cases / population)*100 , 1) AS InfectedPopulation_Percentage
FROM coviddeaths
WHERE location = "Turkey"
ORDER BY total_cases asc, 1,2;


-- Looking at Countries with Highest Infection Rate

SELECT location, population, MAX(total_cases) AS HighestInfection, MAX((total_cases / population)) *100  AS HighestInfectionRate
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfectionRate DESC;


-- Shows Countries with Highest Death Rate 
-- Convert the total_deaths column data type from text file to float 

SELECT location, population, MAX(cast(total_deaths as float)) AS TotalDeath, ROUND(MAX((total_deaths / population))*100, 2) AS HighestDeath_Percantage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeath DESC;


-- Shows the Continents with The Highest Death Count and Highest Death Rate

SELECT continent, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


SELECT continent, population, MAX(cast(total_deaths as float)) AS TotalDeathCount, ROUND(MAX((total_deaths / population))*100, 2) AS TotalDeath_Rate
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent,population
ORDER BY TotalDeathCount DESC;


-- Shows Total Cases vs Continent Population

SELECT continent, date, population, total_cases, ROUND((total_cases / population)*100 , 2) AS TotalCase_per_population
FROM coviddeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
ORDER BY  1,2;


-- Global Data
-- Global Death and Cases

SELECT 
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS float)) AS total_deaths,
	ROUND(SUM(cast(new_deaths AS float)) / SUM(new_cases)*100 ,1) AS DeathPercantage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- JOIN covidvaccinations Table

SELECT * FROM coviddeaths cd
JOIN covidvaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date


-- Total Population vs Vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.total_vaccinations
FROM coviddeaths cd
INNER JOIN covidvaccinations cv
	ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL AND cv.total_vaccinations IS NOT NULL
ORDER BY 2,3;


-- USE CTE to show the percentage of vaccinated people 

WITH PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinatedPeople)
AS(
SELECT
	cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cast(cv.new_vaccinations AS float)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalVaccinatedPoeple
FROM  coviddeaths cd
JOIN covidvaccinations cv
	ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *,  ROUND((TotalVaccinatedPeople / Population)*100, 1) AS PercentPeopleVaccinated
FROM PopvsVac



-- Create a View to Store Data for Visualizations

-- View of Total Vaccinated People Percantage

CREATE VIEW Vaccinated_Percantage AS
WITH PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinatedPeople)
AS(
SELECT
	cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cast(cv.new_vaccinations AS float)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalVaccinatedPoeple
FROM  coviddeaths cd
JOIN covidvaccinations cv
	ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *,  ROUND((TotalVaccinatedPeople / Population)*100, 1) AS PercentPeopleVaccinated
FROM PopvsVac



-- View of Total case and Death Percantage by Date

CREATE VIEW Case_Death_Percantage AS
WITH Case_Death_Percantage 
(date, total_cases, total_deaths, DeathPercantage) AS
(SELECT
	date, 
    SUM(new_cases) as total_cases,
    SUM(cast(new_deaths as float)) as total_deaths,
    ROUND(SUM(cast(new_deaths as float)) / SUM(new_cases)*100 , 2) AS DeathPercantage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
)
SELECT * FROM Case_Death_Percantage;



-- View of Highest Death Percantage

CREATE VIEW Highest_Death_Percantage AS
WITH Highest_Death_Percantage 
(date, total_cases, total_deaths, DeathPercantage) AS
(SELECT
	location,
    population,
    MAX(total_deaths)as Total_Deaths,
    ROUND(MAX((total_deaths / population))*100 ,2) AS Highest_Death_Percantage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
)
SELECT * FROM Highest_Death_Percantage;




-- View of Infected Percantage

CREATE VIEW Infected_Percantage AS
WITH Infected_Percantage(location, date, population, total_cases, infected_percantage) AS
(SELECT
	location,
    date,
    population,
    total_cases,
    ROUND((total_cases / population)*100 , 2) AS infected_percantage
FROM coviddeaths
WHERE continent IS NOT NULL
)
SELECT * FROM Infected_Percantage;


-- View of Highest Infection Percantage

CREATE VIEW Highest_Infected_Percantage AS
WITH Highest_Infected_Percantage(location, date, population, highest_infection,  highest_infection_percantage) AS
(SELECT
	location,
    date,
    population,
    MAX(total_cases) AS highest_infection,
    ROUND(MAX((total_cases / population)*100) ,2) AS highest_infection_percantage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
)
SELECT * FROM Highest_Infected_Percantage;
