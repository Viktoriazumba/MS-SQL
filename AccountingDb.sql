//* 
Database Basics MS SQL Exam – 04 Apr 2023
*//

CREATE DATABASE Accounting

--1
CREATE TABLE Countries
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(10) NOT NULL
)
CREATE TABLE Addresses
(
Id INT PRIMARY KEY IDENTITY,
StreetName NVARCHAR(20) NOT NULL,
StreetNumber INT ,
PostCode INT NOT NULL,
City VARCHAR(25) NOT NULL,
CountryId INT NOT NULL FOREIGN KEY REFERENCES Countries(Id) 
)

CREATE TABLE Vendors
(
Id INT PRIMARY KEY IDENTITY,
[Name] nVARCHAR(25) NOT NULL,
NumberVAT nVARCHAR(15) NOT NULL,
AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id)
)
CREATE TABLE Clients
(
Id INT PRIMARY KEY IDENTITY,
[Name] nVARCHAR(25) NOT NULL,
NumberVAT nVARCHAR(15) NOT NULL,
AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id)
)
CREATE TABLE  Categories
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(10) NOT NULL
)
CREATE TABLE  Products
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(35) NOT NULL,
Price DECIMAL(18,2) NOT NULL,
CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(id),
VendorId INT NOT NULL FOREIGN KEY REFERENCES Vendors(Id)
)

CREATE TABLE  Invoices
(
Id INT PRIMARY KEY IDENTITY,
Number INT UNIQUE NOT NULL,
IssueDate DATETIME2 NOT NULL,
DueDate DATETIME2 NOT NULL,
Amount DECIMAL(18,2) NOT NULL,
Currency VARCHAR(5) NOT NULL,
ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(Id)

)
CREATE TABLE  ProductsClients
(
ProductId INT NOT NULL,
ClientId INT NOT NULL,
CONSTRAINT PK_ProductsClients PRIMARY KEY (ProductId,ClientId),
CONSTRAINT FK_ProductsClients_ProductId FOREIGN  KEY(ProductId) REFERENCES Products(Id),
CONSTRAINT FK_ProductsClients_ClientId FOREIGN  KEY(ClientId) REFERENCES Clients(Id)
)


--2
INSERT INTO Products ([Name],Price,CategoryId,VendorId)
VALUES 
('SCANIA Oil Filter XD01',78.69,1,1),
('MAN Air Filter XD01',97.38,1,5),
('DAF Light Bulb 05FG87',55.00,2,13),
('ADR Shoes 47-47.5',49.85,3,5),
('Anti-slip pads S',5.87,5,7)

INSERT INTO Invoices (Number,IssueDate,DueDate,Amount,Currency,ClientId)
VALUES 
(1219992181,'2023-03-01','2023-04-30',180.96,'BGN',3),
(1729252340,'2022-11-06','2023-01-04',158.18,'EUR',13),
(1950101013,'2023-02-17','2023-04-18',615.15,'USD',19)

--3!
UPDATE Invoices
SET DueDate= '2023-04-01' 
WHERE IssueDate>= '2022-11-01' AND IssueDate<= '2022-11-30';

		UPDATE Clients
		SET AddressId=3
		WHERE [Name] LIKE'%CO%'

		SELECT
		Id
		FROM Addresses
		WHERE StreetName='Industriestr'AND StreetNumber=79 AND PostCode=2353 AND City='Guntramsdorf'

--4
DELETE FROM Invoices
WHERE ClientId=11
DELETE FROM ProductsClients
WHERE ClientId=11
DELETE
FROM Clients
WHERE NumberVAT LIKE 'IT%'

--5
SElECT Number,Currency
FROM Invoices
ORDER BY Amount DESC, DueDate ASC

--6
SELECT p.id,p.[Name],Price,c.[Name] AS CategoryName
FROM Products AS p
JOIN Categories AS c ON c.Id=p.CategoryId
WHERE c.[name] IN ('ADR','Others')
ORDER BY Price DESC

--7

SELECT c.Id,c.[name] AS Client,CONCAT (a.StreetName, ' ',a.StreetNumber,', ',a.City,', ', a.PostCode, ', ',co.[Name]) AS [Address]
FROM Clients AS c
JOIN Addresses as a ON a.Id=c.AddressId
JOIN Countries as co ON co.Id=a.CountryId
LEFT JOIN ProductsClients AS pc ON pc.ClientId=c.Id
WHERE pc.ProductId IS NULL

ORDER BY c.[Name]

--8
SELECT TOP (7) I.Number,i.Amount,c.[Name] AS Client
FROM Invoices AS i
JOIN Clients as c ON c.Id=i.ClientId
WHERE (i.IssueDate < '2023-01-01' AND
i.Currency= 'EUR') OR
(i.Amount > 500.00 and
c.NumberVAT LIKE 'DE%')
ORDER BY i.Number ASC, i.Amount DESC

--9
SELECT c.[Name] AS Client,MAX(p.Price), c.NumberVAT AS [VAT Number]
FROM Clients AS c
JOIN ProductsClients AS pc ON pc.ClientId=c.Id
JOIN Products AS p ON p.Id=pc.ProductId
WHERE c.[Name] NOT LIKE '%KG'
GROUP BY c.[Name],c.[NumberVAT]
ORDER BY MAX(p.Price) DESC

--10
SELECT c.[Name] AS Client, FLOOR(AVG(p.Price)) AS [Average Price]
FROM Clients AS c
JOIN ProductsClients AS pc ON pc.ClientId=c.Id
JOIN Products AS p ON p.Id=pc.ProductId
JOIN Vendors AS v ON v.Id=p.VendorId

WHERE v.NumberVAT LIKE '%FR%'

GROUP BY c.[Name]
ORDER BY AVG(p.Price), c.[Name] DESC

--11
CREATE OR ALTER FUNCTION  udf_ProductWithClients(@name NVARCHAR(30))
RETURNS INT
AS
BEGIN
RETURN(
SELECT COUNT(*) FROM Products AS p
JOIN ProductsClients AS c ON c.ProductId=p.Id
WHERE [Name]=@name
)
END
SELECT dbo.udf_ProductWithClients('DAF FILTER HU12103X')


--12

CREATE OR ALTER PROC usp_SearchByCountry(@country varchar(50))
AS
BEGIN
SELECT v.[Name] AS Vendor ,
v.NumberVAT AS VAT,
CONCAT (a.StreetName, ' ' , a.StreetNumber ) AS [Street Info],
CONCAT (A.City, ' ' , a.PostCode) AS [City Info]


FROM Vendors AS v 
JOIN Addresses AS a ON a.id=v.AddressId
JOIN Countries AS c ON c.Id=a.CountryId
WHERE c.[Name]=@country

ORDER BY V.[Name], City


END
EXEC usp_SearchByCountry 'France'

