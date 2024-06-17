//*
Database Basics MS SQL Exam – 10.08.2022
*//

CREATE DATABASE NationalTouristSitesOfBulgaria

 --01. DDL


	CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR (50) NOT NULL
	);



	CREATE TABLE Locations(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR (50) NOT NULL
	,Municipality VARCHAR (50) 
	,Province VARCHAR (50)
	);


	CREATE TABLE Sites(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR (100) NOT NULL
	,LocationId INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL
	,CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
	,Establishment VARCHAR (15) 
	);


	CREATE TABLE Tourists (
		Id INT PRIMARY KEY IDENTITY
	   ,Name VARCHAR (50) NOT NULL
	   ,Age INT CHECK(Age>=0 AND Age<=120) NOT NULL
	   ,PhoneNumber VARCHAR (20) NOT NULL
	   ,Nationality VARCHAR (30) NOT NULL
	   ,Reward VARCHAR (20) 
	);


	CREATE TABLE SitesTourists(
	TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL
	,SiteId INT FOREIGN KEY REFERENCES Sites(Id) NOT NULL
	PRIMARY KEY (TouristId,SiteId)
	);


	CREATE TABLE BonusPrizes(
	    Id INT PRIMARY KEY IDENTITY
	   ,Name VARCHAR (50) NOT NULL
	);



	CREATE TABLE TouristsBonusPrizes(
	TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL
	,BonusPrizeId INT FOREIGN KEY REFERENCES BonusPrizes(Id) NOT NULL
	PRIMARY KEY (TouristId,BonusPrizeId)
	);

	--02. Insert


	
	INSERT INTO Tourists(Name, Age, PhoneNumber, Nationality, Reward)
		VALUES
		 ('Borislava Kazakova', 52,	'+359896354244', 'Bulgaria', NULL)
		,('Peter Bosh',	48,	'+447911844141', 'UK',	NULL)
		,('Martin Smith', 29,	'+353863818592','Ireland',	'Bronze badge')
		,('Svilen Dobrev',	49,	'+359986584786', 'Bulgaria','Silver badge')
		,('Kremena Popova',	38,	'+359893298604',	'Bulgaria',	NULL);



	INSERT INTO Sites(Name,	LocationId,	CategoryId	,Establishment)
	VALUES
	('Ustra fortress',	90	,7,'X')
	,('Karlanovo Pyramids',	65,	7,	NULL)
	,('The Tomb of Tsar Sevt',	63,	8,	'V BC')
	,('Sinite Kamani Natural Park',	17,	1,	NULL)
	,('St. Petka of Bulgaria – Rupite',	92	,6	,'1994');

	--3
	UPDATE Sites
	SET Establishment= '(not defined)' 
	WHERE Establishment IS NULL

	--4
	

	DELETE TouristsBonusPrizes
	WHERE BonusPrizeId=5

	DELETE BonusPrizes
	WHERE [Name]='Sleeping bag'

	--5
	SELECT [Name],age,PhoneNumber,Nationality
	FROM Tourists
	ORDER BY Nationality ASC, Age DESC, [Name] ASC

	--6
	SELECT s.[Name] AS [Site],
	l.[Name] AS [Location],
	s.Establishment,
	c.[Name] AS Category

	FROM Sites AS s
	JOIN Locations AS l ON l.Id=s.LocationId
	JOIN Categories AS c ON c.Id=s.CategoryId

	ORDER BY c.[Name] DESC,l.[Name] ASC,s.[Name] ASC

	--7
	SELECT Province,Municipality,l.[name], COUNT(s.Id) AS CountOfSites
	FROM Locations AS l
	JOIN Sites AS s ON s.LocationId=l.Id
	WHERE Province= 'Sofia'
	GROUP BY l.Province,l.Municipality,l.[Name]
	
	ORDER BY CountOfSites DESC, l.[Name] ASC

	--8
	SELECT s.[Name] AS [Site],l.[Name] AS [Location],Municipality,Province,Establishment
	FROM Sites AS s
	JOIN Locations AS l ON l.Id=s.LocationId
	WHERE l.[Name] NOT LIKE 'B%' AND
	l.[Name] NOT LIKE 'M%' AND
	l.[Name] NOT LIKE 'D%' AND
	Establishment LIKE '%BC%'
	ORDER BY [Site]

	--9
	SELECT t.[Name],T.Age,t.PhoneNumber,t.Nationality,
	
	ISNULL(b.[name], '(no bonus prize)') AS Reward

	
	FROM Tourists AS t
	LEFT JOIN TouristsBonusPrizes AS tb ON tb.TouristId=t.Id
	LEFT JOIN BonusPrizes AS b ON B.Id=tb.BonusPrizeId

	ORDER BY T.[name]

	--10 izvlichane na familia
	SELECT SUBSTRING(t.[name],CHARINDEX(' ' , t.[Name])+1,LEN(t.[Name])) AS [last Name],
	t.Nationality,t.age,t.PhoneNumber
	FROM Tourists AS t
	JOIN SitesTourists AS st ON st.TouristId=t.Id
	JOIN Sites AS s ON s.Id=st.SiteId
	JOIN Categories AS c ON c.Id=s.CategoryId
	
	WHERE c.[Name]='History and archaeology'
	GROUP BY SUBSTRING(t.[name],CHARINDEX(' ' , t.[Name])+1,LEN(t.[Name])) ,
	t.Nationality,t.age,t.PhoneNumber
	ORDER BY [last Name]

	--11
	CREATE OR ALTER FUNCTION udf_GetTouristsCountOnATouristSite (@Site VARCHAR(50))
	RETURNS INT
AS
BEGIN
RETURN(
SELECT COUNT(TouristID)
FROM SitesTourists AS st
JOIN Sites AS s ON s.Id=st.SiteId
JOIN Tourists AS t ON t.Id=st.TouristId
WHERE s.[Name]=@Site
)
END
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Regional History Museum – Vratsa')
	--12

CREATE OR ALTER PROCEDURE  usp_AnnualRewardLottery(@TouristName VARCHAR(50))
AS
BEGIN 
DECLARE @site_count INT;

SELECT @site_count= COUNT(st.SiteId)
FROM Tourists AS t
JOIN SitesTourists AS st ON st.TouristId=t.Id
where t.[Name]=@TouristName

UPDATE Tourists
SET Reward= CASE
 WHEN @site_count >= 100 THEN 'Gold badge'
        WHEN @site_count >= 50 THEN 'Silver badge'
        WHEN @site_count >= 25 THEN 'Bronze badge'
        ELSE NULL
    END
    WHERE Name = @TouristName;
	SELECT [name],Reward
	FROM Tourists
	WHERE [Name]=@TouristName
END;

EXEC usp_AnnualRewardLottery 'Gerhild Lutgard'

