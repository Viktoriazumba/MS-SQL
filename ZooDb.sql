CREATE DATABASE Zoo

--01. DDL



	CREATE TABLE Owners(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR (50) NOT NULL
	,PhoneNumber VARCHAR (15) NOT NULL
	,Address VARCHAR (50) 
	);

	

	CREATE TABLE AnimalTypes(
	Id INT PRIMARY KEY IDENTITY
	,AnimalType VARCHAR (30) NOT NULL
	);


	
	CREATE TABLE Cages(
	Id INT PRIMARY KEY IDENTITY
	,AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
	);


	CREATE TABLE Animals(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR (30) NOT NULL
	,BirthDate	DATE NOT NULL
	,OwnerId INT  FOREIGN KEY REFERENCES Owners(Id) 
	,AnimalTypeId INT  FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
	);


	CREATE TABLE AnimalsCages(
	CageId INT  FOREIGN KEY REFERENCES Cages(Id) NOT NULL
	,AnimalId INT  FOREIGN KEY REFERENCES Animals(Id) NOT NULL
	PRIMARY KEY (CageId,AnimalId)
	);



	CREATE TABLE VolunteersDepartments(
	Id INT PRIMARY KEY IDENTITY
	,DepartmentName VARCHAR (30) NOT NULL
	);


	CREATE TABLE Volunteers(
	Id INT PRIMARY KEY IDENTITY
		,[Name] VARCHAR (50) NOT NULL
		,PhoneNumber VARCHAR (15) NOT NULL
		,[Address] VARCHAR (50) 
		,AnimalId INT  FOREIGN KEY REFERENCES Animals(Id)
		,DepartmentId INT  FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
	);

	--02. Insert


	INSERT INTO Animals([Name],	BirthDate)
	VALUES 
	('Giraffe',	'2018-09-21')
	,('Harpy Eagle','2015-04-17')
	,('Hamadryas Baboon','2017-11-02')
	,('Tuatara','2021-06-30')



	INSERT INTO Volunteers([Name],PhoneNumber,[Address])
	VALUES
	('Anita Kostova','0896365412'	,'Sofia, 5 Rosa str.')
	,('Dimitur Stoev','0877564223',null)
	,('Kalina Evtimova','0896321112','Silistra, 21 Breza str.')
	,('Stoyan Tomov','0898564100','Montana, 1 Bor str.')
	,('Boryana Mileva','0888112233',null);

	--3
	SELECT Id FROM Owners
	WHERE [name]='Kaloqn Stoqnov'

	UPDATE Animals
	SET OwnerId=4
	WHERE OwnerId IS NULL

	--4
	SELECT ID FROM VolunteersDepartments
	WHERE DepartmentName='Education program assistant'

	DELETE FROM Volunteers
	WHERE DepartmentId=2

	DELETE FROM VolunteersDepartments
	WHERE ID=2

	--5
	SELECT [name],PhoneNumber,[Address],AnimalId,DepartmentId
	FROM Volunteers
	ORDER BY [Name] ASC,AnimalId ASC,DepartmentId ASC

	--6
	SELECT a.[Name],aty.[AnimalType],FORMAT(BirthDate,'dd.MM.yyyy') AS BirthDate
	FROM Animals AS a
	JOIN AnimalTypes AS aty ON aty.Id=a.AnimalTypeId
	
ORDER BY a.[Name]

--7
SELECT top(5) o.[Name] AS [Owner],COUNT(a.Id) AS CountOfAnimals

FROM Owners AS o
JOIN Animals AS a ON a.OwnerId=o.Id
GROUP BY o.[Name]
ORDER BY COUNT(a.Id) DESC,o.[Name] 

--8
SELECT CONCAT(o.[Name],'-',a.[Name]) AS OwnersAnimals,o.PhoneNumber,c.Id as CageId
FROM Owners AS o
JOIN Animals AS a ON a.OwnerId=o.Id
JOIN AnimalsCages AS ac ON ac.AnimalId=a.Id
JOIN Cages AS c on c.Id=ac.CageId
JOIN AnimalTypes AS aty ON aty.Id=a.AnimalTypeId
WHERE AnimalType='mammals'
ORDER BY o.[Name], a.[Name] DESC

--9
SELECT v.[Name],PhoneNumber,SUBSTRING([Address],CHARINDEX(',' , [Address])+1,LEN([Address])) AS [Address]
FROM Volunteers AS v
JOIN VolunteersDepartments AS vd ON vd.Id=v.DepartmentId
WHERE DepartmentName='Education program assistant' AND
[Address] LIKE '%Sofia%'
ORDER BY v.[Name]

--10
SELECT a.[Name],YEAR(a.BirthDate) AS BirthYear,aty.AnimalType

FROM Animals AS a
JOIN AnimalTypes AS aty ON aty.Id=a.AnimalTypeId

WHERE a.OwnerId IS NULL AND 
(DATEDIFF(YEAR, a.BirthDate,'01/01/2022')<5) AND
aty.AnimalType <> 'Birds'

ORDER BY a.[Name]

--11
CREATE OR ALTER FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(50))
RETURNS INT
AS
BEGIN
RETURN(SELECT
COUNT(v.Id)
FROM Volunteers AS v
JOIN VolunteersDepartments AS vd ON vd.Id=v.DepartmentId
WHERE vd.DepartmentName=@VolunteersDepartment
)end
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Education program assistant')

--12
CREATE OR ALTER PROCEDURE usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(50))
AS
BEGIN
SELECT a.[Name] AS [Name],CASE WHEN o.[Name] IS NULL THEN 'For adoption'
ELSE
o.[Name]
END AS OwnerName

FROM Animals AS a

LEFT JOIN Owners AS o ON o.Id=a.OwnerId

Where a.[Name]=@AnimalName 



END
EXEC usp_AnimalsWithOwnersOrNot 'Pumpkinseed Sunfish'