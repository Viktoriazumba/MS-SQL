//* 
Create a database called TouristAgency. You need to create 7 tables:
    • Countries – contains information about the countries, in which the destinations and hotels are located, each tourist will also has a country;
    • Destinations – contains information about the holiday destinations(areas, resorts, etc.);
    • Rooms – contains information about the rooms (type of room, count of beds);
    • Hotels – contains information about each hotel;
    • Tourists – containts information about each tourist, that has booked a room in a hotel;
    • Bookings – contains information about each booking;
    • HotelsRooms  – mapping table between hotels and rooms;

*//
--1
CREATE DATABASE TouristsAgency
CREATE TABLE Countries
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Destinations
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50),
CountryId INT NOT NULL FOREIGN KEY REFERENCES Countries(Id) 
)

CREATE TABLE Rooms
(
Id INT PRIMARY KEY IDENTITY,
[Type] VARCHAR(40) NOT NULL,
Price DECIMAL(18,2) NOT NULL,
BedCount INT  NOT NULL
	 CHECK(BedCount>0 AND BedCount <=10)
)
CREATE TABLE Hotels
(
Id INT PRIMARY KEY IDENTITY ,
[Name] VARCHAR(50) NOT NULL,
DestinationId INT NOT NULL FOREIGN KEY REFERENCES Destinations(Id) 
)

CREATE TABLE Tourists
(
Id INT PRIMARY KEY IDENTITY ,
[Name] NVARCHAR(80) NOT NULL,
PhoneNumber NVARCHAR(20) NOT NULL,
Email NVARCHAR(80) ,
CountryId INT NOT NULL FOREIGN KEY REFERENCES Countries(Id) 
)

CREATE TABLE  Bookings
(
Id INT PRIMARY KEY IDENTITY ,
ArrivalDate DATETIME2 NOT NULL,
DepartureDate DATETIME2 NOT NULL,
AdultsCount INT  NOT NULL
CHECK(AdultsCount>=1 AND AdultsCount <=10),
ChildrenCount INT  NOT NULL
CHECK(ChildrenCount>=0 AND ChildrenCount <=19),
TouristId INT NOT NULL FOREIGN KEY REFERENCES Tourists(ID),
HotelId INT NOT NULL FOREIGN KEY REFERENCES Hotels(Id),
RoomId INT NOT NULL FOREIGN KEY REFERENCES Rooms(Id)

)

CREATE TABLE HotelsRooms
(
HotelId INT NOT NULL ,
RoomId INT NOT NULL 
CONSTRAINT PK_HotelRooms PRIMARY KEY (HotelId,RoomId),
CONSTRAINT FK_HotelRooms_Hotels FOREIGN  KEY(HotelId) REFERENCES HotelS(Id),
CONSTRAINT FK_HotelRooms_Rooms FOREIGN  KEY(RoomId) REFERENCES Rooms(Id)
)
//* 
Let's insert some sample data into the database. Write a query to add the following records into the corresponding tables. All IDs (Primary Keys) should be auto-generated.
*//

--2
INSERT INTO Tourists ([Name],PhoneNumber,Email,CountryId)
VALUES ('John Rivers','653-551-1555','john.rivers@example.com',6),
('Adeline Aglaé','122-654-8726','adeline.aglae@example.com',2),
('Sergio Ramirez','233-465-2876','s.ramirez@example.com',3),
('Johan Müller','322-876-9826','j.muller@example.com',7),
('Eden Smith','551-874-2234','eden.smith@example.com',6)


INSERT INTO Bookings (ArrivalDate,DepartureDate, AdultsCount,ChildrenCount,TouristId,HotelId,RoomId)
VALUES
('2024-03-01','2024-03-11',1,0,21,3,5),
('2023-12-28','2024-01-06',2,1,22,13,3),
('2023-11-15','2023-11-20',1,2,23,19,7),
('2023-12-05','2023-12-09',4,0,24,6,4),
('2024-05-01','2024-05-07',6,0,25,14,6)


--3
//* 
We've decided to change the departure date of the bookings that are scheduled to arrive in December 2023. The updated departure date for these bookings should be set to one day later than their original departure date.
We need to update the email addresses of tourists, whose names contain "MA". The new value of their email addresses should be set to NULL.
*//
UPDATE Bookings
SET DepartureDate= DATEADD(DAY,1, DepartureDate)
WHERE ArrivalDate>='2023-12-01' AND ArrivalDate <='2023-12-31'

UPDATE Tourists
SET Email=NULL
WHERE[Name] like '%MA%'

--4
//* 
In table Tourists, delete every tourist, whose Name contains family name "Smith". Keep in mind that there could be foreign key constraint conflicts.
*//
BEGIN TRANSACTION
DECLARE @TouristsIsDeleted TABLE (Id INT)
INSERT INTO @TouristsIsDeleted(iD)
SELECT Id
FROM Tourists
WHERE [Name] LIKE '%Smith%'

DELETE FROM Bookings
WHERE TouristId IN (SELECT Id from @TouristsIsDeleted)
DELETE FROM Tourists
WHERE Id IN (SELECT Id From @TouristsIsDeleted)
COMMIT

--5
//* 
Select all bookings, ordered by price  of room (descending), then by arrival date (ascending). The arrival date should be formatted in the 'yyyy-MM-dd' format in the query results.
Required columns:
    • ArrivalDate
    • AdultsCount
    • ChildrenCount
*//
SELECT FORMAT(ArrivalDate,'yyyy-MM-dd') AS ArrivalDate
,AdultsCount,ChildrenCount 

FROM Bookings AS b
JOIN Rooms AS r
ON r.Id=b.RoomId

ORDER BY r.Price DESC, ArrivalDate ASC


--6
//* 
Select all hotels with "VIP Apartment" available. Order results by the count of bookings (count of all bookings for the specific hotel, not only for VIP apartment) made for every hotel (descending).
Required columns:
    • Id
    • Name
*//
SELECT h.ID,h.[name]
FROM Hotels AS h
JOIN HotelsRooms AS hr
ON hr.HotelId=h.Id
JOIN Rooms AS r
ON r.Id=hr.RoomId
JOIN Bookings AS b
ON b.HotelId=h.Id AND r.Type='VIP Apartment'
GROUP BY h.Id, h.[Name]
ORDER BY COUNT(*)DESC

--7
//* 
Select all tourists that haven’t booked a hotel yet. Order them by name (ascending).
Required columns:
    • Id
    • Name
    • PhoneNumber
*//
SELECT Id,[name],PhoneNumber
FROM Tourists
WHERE Id NOT IN (SELECT TouristID FROM Bookings)
ORDER BY [Name] ASC


--8
//* 
Select the first 10 bookings that will arrive before 2023-12-31. You will need to select the bookings in hotels with odd-numbered IDs. Sort the results in ascending order, first by CountryName, and then by ArrivalDate.
Required columns:
    • HotelName
    • DestinationName
    • CountryName
*//
SELECT TOP(10) h.[Name] AS HotelName,
d.[Name]AS DestinationName,
c.[Name] AS CountryName
FROM Bookings AS b
JOIN Hotels AS h
ON h.Id=b.HotelId
JOIN Destinations AS d
ON d.Id=h.DestinationId
JOIN Countries AS c
ON c.Id=d.CountryId
WHERE ArrivalDate < '2023-12-31' AND 
h.ID % 2!=0
ORDER BY c.[Name] ASC, ArrivalDate ASC

--9
//* 
Select all of the tourists that have a name, not ending in "EZ", and display the names of the hotels, that they have booked a room in. Order by the price of the room (descending).
Required columns:
    • HotelName
    • RoomPrice
*//
SELECT h.[Name] AS HotelName, Price AS RoomPrice
FROM Tourists AS t
JOIN Bookings AS b
ON b.TouristId=t.Id
JOIN Hotels AS h
ON h.Id=b.HotelId
JOIN Rooms AS r
On r.Id=b.RoomId

WHERE t.[Name] NOT LIKE '%EZ'
ORDER BY Price DESC

--10
//* 
In this task, you will write an SQL query to calculate the total price of all bookings for each hotel based on the room price and the number of nights guests have stayed. The result should list the hotel names and their corresponding revenue.
    • Foreach Booking you should join data for the Hotel and the Room, using the Id references;
    • NightsCount – you will need the ArrivalDate and DepartureDate for a DATEDIFF function;
    • Calculate the TotalRevenue by summing the price of each booking, using Price of the Room that is referenced to the specific Booking and multiply it by the NightsCount. 
    • Group all the bookings by HotelName using the reference to the Hotel. 
    • Order the results by TotalRevenue in descending order.
Required columns:
    • HotelName
    • TotalRevenue
*//

SELECT h.[Name] AS HotelName,
SUM(price*DATEDIFF(DAY,ArrivalDate,DepartureDate)) AS HotelRevenue
FROM Hotels AS h
JOIN Bookings AS b
ON b.HotelId=h.Id
JOIN Rooms AS r
on R.Id=b.RoomId

GROUP BY h.[Name]

ORDER BY HotelRevenue DESC

--11
//* 
Create a user-defined function, named udf_RoomsWithTourists(@name) that receives a room's type.
The function should return the total number of tourists that the specific room type has been booked for (adults + children).
Hint: A Double Room could be booked for: 2 adults + 0 children, 1 adult + 1 children, 1 adult + 0 children.
*//
CREATE FUNCTION udf_RoomsWithTourists(@name VARCHAR(50)) --za funkcia triabva da imame return
RETURNS INT
AS
BEGIN

RETURN
( SELECT
SUM(AdultsCount+ChildrenCount)
FROM Bookings AS b
JOIN Rooms AS r
ON R.Id=b.RoomId
WHERE [Type]=@name)
END
SELECT dbo.udf_RoomsWithTourists('Double Room')

--12
//* 
Create a stored procedure, named usp_SearchByCountry(@country) that receives a country name. The procedure must print full information about all tourists that have an booked a room and have origin from the given country: Name, PhoneNumber, Email and CountOfBookings (the count of all bookings made). Order them by Name (ascending) and CountOfBookings (decending).
*//
CREATE PROCEDURE usp_SearchByCountry(@country VARCHAR(50))
AS
BEGIN

SELECT t.[Name] AS [Name],
PhoneNumber,
Email,
COUNT(b.Id)  AS CountOfBookings
FROM Tourists AS t
JOIN Bookings AS b
ON b.TouristId=t.Id
JOIN Countries AS c
ON c.Id=T.CountryId
WHERE c.[Name]=@country
GROUP BY t.[Name],PhoneNumber,Email
ORDER BY t.[Name] ASC, CountOfBookings DESC

END

EXEC usp_SearchByCountry 'Greece'