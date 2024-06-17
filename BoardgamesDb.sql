//* 
Database Basics MS SQL Exam – 12 Feb 2023
*//
CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR (50) NOT NULL
	);


	CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY
	,StreetName NVARCHAR(100) NOT NULL
	,StreetNumber INT NOT NULL
	,Town VARCHAR (30) NOT NULL
	,Country VARCHAR (50) NOT NULL
	,ZIP INT NOT NULL
	);


	CREATE TABLE Publishers(
	Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(30) NOT NULL
	,AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id)
	,Website NVARCHAR(40) 
	,Phone NVARCHAR (20) 
	);
	
	
	CREATE TABLE PlayersRanges(
	Id INT PRIMARY KEY IDENTITY
	,PlayersMin INT NOT NULL
	,PlayersMax INT NOT NULL
	);


	
	CREATE TABLE Boardgames(
	Id  INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR (30) NOT NULL
	,YearPublished INT NOT NULL
	,Rating DECIMAL (5,2) NOT NULL
	,CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id)
	,PublisherId INT NOT NULL FOREIGN KEY REFERENCES Publishers(Id)
	,PlayersRangeId INT NOT NULL FOREIGN KEY REFERENCES PlayersRanges(Id)
	);


	CREATE TABLE Creators(
	Id  INT PRIMARY KEY IDENTITY
	,FirstName NVARCHAR (30) NOT NULL
	,LastName NVARCHAR (30) NOT NULL
	,Email NVARCHAR (30) NOT NULL
	);


	CREATE TABLE CreatorsBoardgames(
	CreatorId INT NOT NULL FOREIGN KEY REFERENCES Creators(Id)
	,BoardgameId INT NOT NULL FOREIGN KEY REFERENCES Boardgames(Id)
	PRIMARY KEY(CreatorId,BoardgameId)
	);

	--2
	 INSERT INTO Boardgames([Name],YearPublished,Rating,CategoryId,PublisherId,PlayersRangeId)
	 VALUES 
	 ('Deep Blue',2019,	5.67,1,	15 ,7)
	 ,('Paris',	2016,	9.78,	7,	1,	5)
	 ,('Catan: Starfarers',	2021,	9.87	,7	,13	,6)
	 ,('Bleeding Kansas',	2020,	3.25,	3,	7,	4)
	 ,('One Small Step',	2019,	5.75,	5,	9,	2);


	INSERT INTO Publishers([Name],	AddressId,	Website,	Phone)
	VALUES
	('Agman Games',	5	,'www.agmangames.com',	'+16546135542')
	,('Amethyst Games',	7,	'www.amethystgames.com',	'+15558889992')
	,('BattleBooks',	13	,'www.battlebooks.com',	'+12345678907');

	--3

UPDATE PlayersRanges
SET PlayersMax = PlayersMax+1
WHERE PlayersMin=2 AND PlayersMax=2
UPDATE Boardgames
SET [Name]= CONCAT([Name],'V2')
WHERE YearPublished >=2020

--4
SELECT*FROM Addresses
WHERE Town LIKE 'l%'
SELECT*FROM Publishers
WHERE AddressId=5
SELECT*FROM Boardgames
WHERE PublisherId  IN (1,16)
SELECT*FROM CreatorsBoardgames
WHERE CreatorId IN (1,16,31,47)

DELETE CreatorsBoardgames
WHERE BoardgameId IN (1,16,31,47)
DELETE Boardgames
WHERE PublisherId  IN (1,16)
DELETE Publishers
WHERE AddressId=5
delete Addresses
WHERE Town LIKE 'l%'


--5
SELECT [name],Rating
FROM Boardgames
ORDER BY YearPublished ASC, [Name] DESC

--6

SELECT b.ID,b.[name],YearPublished,c.[Name] AS CategoryName
FROM Boardgames AS b
JOIN Categories AS c ON c.Id=b.CategoryId
WHERE c.[Name] ='Strategy Games' OR  c.[Name] ='Wargames'
order by YearPublished DESC

--7

SELECT c.id,CONCAT(FirstName, ' ' , LastName) AS CreatorName,Email
FROM Creators AS c
LEFT JOIN CreatorsBoardgames AS cb ON cb.CreatorId=c.Id
WHERE cb.BoardgameId IS NULL
order by CreatorName

--8
SELECT TOP(5) b.[name] AS [Name],Rating,C.[Name] AS CategoryName
FROM Boardgames AS b
JOIN Categories AS c ON c.Id=b.CategoryId
JOIN PlayersRanges AS pr ON pr.Id=b.PlayersRangeId
WHERE (Rating > 7.00 AND b.[Name] LIKE '%a%' ) OR (Rating>7.50 AND PlayersMin>2 AND PlayersMax>5)
order by b.[Name] ASC, Rating DESC

--9
SELECT CONCAT_WS(' ', FirstName,LastName) AS FullName,Email,MAX(Rating) AS MaxRating
FROM Creators AS c
JOIN CreatorsBoardgames AS cb ON cb.CreatorId=c.Id
JOIN Boardgames AS b ON b.Id=cb.BoardgameId
WHERE c.Email like '%.com'
GROUP BY  c.FirstName,c.LastName,c.Email
ORDER BY FullName

--10
SELECT c.LastName,CEILING(AVG(b.Rating)) AS AverageRating,p.[Name] AS [PublisherName]
FROM Creators AS c
JOIN CreatorsBoardgames AS cb ON cb.CreatorId=c.Id
JOIN Boardgames AS b ON b.Id=cb.BoardgameId
JOIN Publishers AS p On p.Id=b.PublisherId
WHERE p.[name] = 'Stonemaier Games'
GROUP BY c.LastName,p.[name]
ORDER BY AVG(b.Rating) DESC


--11
CREATE OR ALTER FUNCTION udf_CreatorWithBoardgames(@name VARCHAR(50))
RETURNS INT
AS
BEGIN
RETURN(
SELECT COUNT(BoardgameId)
FROM Creators AS c
JOIN CreatorsBoardgames AS cb ON cb.CreatorId=c.Id
JOIN Boardgames AS b ON b.Id=cb.BoardgameId
WHERE c.[FirstName]=@name
)
END

SELECT dbo.udf_CreatorWithBoardgames('Bruno')

--12
CREATE OR ALTER PROCEDURE usp_SearchByCategory(@category VARCHAR(50))
AS
BEGIN
SELECT b.[Name],b.YearPublished,Rating,c.[Name] AS CategoryName,
p.[Name] AS PublisherName,CONCAT(PlayersMin,' ' , 'people')AS MinPlayers,CONCAT(PlayersMax,' ' , 'people') AS MaxPlayers
FROM Boardgames AS b
JOIN Categories AS c ON c.Id=b.CategoryId
JOIN Publishers AS p ON p.Id=b.PublisherId
JOIN PlayersRanges AS pr ON pr.Id=b.PlayersRangeId
WHERE c.[name]=@category
ORDER BY p.[Name] ASC, b.YearPublished DESC
END

EXEC usp_SearchByCategory 'Wargames'





--12