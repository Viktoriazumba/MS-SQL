//* 
Database Basics MS SQL Regular Exam – 16 Jun 2024
*//

CREATE DATABASE LibraryDb
--1
//* 
Create a database called LibraryDb. You need to create 6 tables:
    • Books – contains information about each book;
    • Authors – contains information about the authors of the books;
    • Libraries – contains information about each library;
    • Genres – contains information about the book’s category;
    • Contacts – contains information about the contact methods with the libraries or the authors;
    • LibrariesBooks - manages the many-to-many relationship between libraries and books, indicating which libraries store specific books and which books are stored in a specific library;
*//
CREATE TABLE Genres
(Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL
)
CREATE TABLE Contacts
(Id INT PRIMARY KEY IDENTITY,
Email NVARCHAR(100) ,
PhoneNumber NVARCHAR(20) ,
PostAddress NVARCHAR(200),
Website NVARCHAR(50) ,
)


CREATE TABLE Authors
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(100) NOT NULL,
ContactId INT NOT NULL FOREIGN KEY REFERENCES Contacts(id)
)



CREATE TABLE Books
(
Id INT PRIMARY KEY IDENTITY,
Title NVARCHAR(100) NOT NULL,
YearPublished INT NOT NULL,
ISBN NVARCHAR(13) NOT NULL UNIQUE,
AuthorId INT NOT NULL FOREIGN KEY REFERENCES Authors(Id),
GenreId INT NOT NULL FOREIGN KEY REFERENCES Genres(Id) ,

)

CREATE TABLE Libraries
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
ContactId INT NOT NULL FOREIGN KEY REFERENCES Contacts(id)
)
CREATE TABLE LibrariesBooks
(
LibraryId INT NOT NULL ,
BookId INT NOT NULL ,
CONSTRAINT PK_LibrariesBooks PRIMARY KEY (LibraryId,BookId),
CONSTRAINT FK_LibrariesBooks_Library FOREIGN  KEY(LibraryId) REFERENCES Libraries(Id),
CONSTRAINT FK_LibrariesBooks_Rooms FOREIGN  KEY(BookId) REFERENCES Books(Id)

)
--2
//* 
Let's insert some sample data into the database. Write a query to add the following records to the corresponding tables. All IDs (Primary Keys) should be auto-generated.
*//
INSERT INTO Contacts(Email,PhoneNumber,PostAddress,Website)
VALUES (NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,NULL),
('stephen.king@example.com','+4445556666','15 Fiction Ave, Bangor, ME','www.stephenking.com'),
('suzanne.collins@example.com','+7778889999','10 Mockingbird Ln, NY, NY','www.suzannecollins.com')

INSERT INTO Authors ([Name],ContactId)
VALUES ('George Orwell',21),
('Aldous Huxley',22),
('Stephen King',23),
('Suzanne Collins',24)

INSERT INTO Books (Title,YearPublished,ISBN,AuthorId,GenreId)
VALUES ('1984',1949,'9780451524935',16,2),
('Animal Farm',1945,'9780451526342',16,2),
('Brave New World',1932,'9780060850524',17,2),
('The Doors of Perception',1954,'9780060850531',17,2),
('The Shining',1977,'9780307743657',18,9),
('It',1986,'9781501142970',18,9),
('The Hunger Games',2008,'9780439023481',19,7),
('Catching Fire',2009,'9780439023498',19,7),
('Mockingjay',2010,'9780439023511',19,7)

INSERT INTO LibrariesBooks 
VALUES (1,36),
(1,37),
(2,38),
(2,39),
(3,40),
(3,41),
(4,42),
(4,43),
(5,44)

--3
//* 
For all authors who do not have a website listed in their contact information, update their contact information to include a website. The website should be in the format: "www." + "authorname" + ".com"
'authorname' -> in lowercase without spaces
'George Orwell' -> www.georgeorwell.com
*//
UPDATE Contacts
SET Website = 'www.' + REPLACE(LOWER(a.[Name]), ' ', '') + '.com'
FROM Contacts AS c
JOIN Authors  AS a ON a.ContactId = C.Id
WHERE c.Website IS NULL OR c.Website = '';

--4
//* 
You are required to delete 'Alex Michaelides' from the Authors table. This is challenging because the Authors table is referenced by the Books table, which in turn is referenced by the LibrariesBooks table. Therefore, you need to handle these references correctly to maintain the integrity of the database.
*//
DELETE FROM LibrariesBooks
WHERE BookId=1
DELETE FROM Books
WHERE AuthorId=1
DELETE FROM Authors
WHERE [Name]='Alex Michaelides'

--5
//* 
Select all books, ordered by year of publication – descending, and then by title - alphabetically.
Required columns:
    • Book Title
    • ISBN
    • YearReleased
*//
SELECT Title AS [Book Title], ISBN,YearPublished AS [Year Released]
FROM Books
ORDER BY YearPublished DESC, Title ASC

--6
//* 
Select all books with 'Biography' or 'Historical Fiction' genres. Order results by Genre, and then by book title – alphabetically.
Required columns:
    • Id
    • Title
    • ISBN
    • Genre
*//
SELECT b.Id,Title,ISBN,g.[Name] AS Genre
FROM Books AS b
JOIN Genres AS g ON g.id=b.genreId

WHERE g.[Name] LIKE 'Biography' or 
g.[Name] LIKE 'Historical Fiction'

ORDER BY G.[Name],b.[Title]

--7
//* 
Select all libraries that do not have any books of a specific genre ('Mystery'). Order the results by the name of the library in ascending order.
Required columns:
    • Library
    • Email
*//
SELECT l.[Name] AS [Library], c.Email
FROM Libraries AS l
JOIN Contacts AS c ON c.Id = l.ContactId
WHERE NOT EXISTS (
    SELECT 1
    FROM LibrariesBooks AS lb
    JOIN Books AS b ON b.Id = lb.BookId
    JOIN Genres AS g ON g.Id = b.GenreId
    WHERE lb.LibraryId = l.Id
      AND g.[Name] = 'Mystery'
)
ORDER BY l.[Name] ASC;

--8
//* 
Your task is to write a query to select the first 3 books from the library database (LibraryDb) that meet the following criteria:
    • The book was published after the year 2000 and contains the letter 'a' in the book title, 
    • OR
    • The book was published before 1950 and the genre name contains the word 'Fantasy'.
The results should be ordered by the book title in ascending order, and then by the year published in descending order.
Required columns:
    • Title
    • Year
    • Genre
*//
SELECT TOP(3) b.Title,YearPublished AS [Year],g.[Name] AS Genre
FROM Books AS b
JOIN Genres AS g ON g.Id=b.GenreId

WHERE (b.YearPublished > 2000 AND b.Title LIKE '%a%')  or
(b.YearPublished<1950 AND G.[Name] LIKE '%Fantasy%')

ORDER BY b.Title ASC, b.YearPublished DESC


--9
//* 
Your task is to write a query to select all authors from the UK (their PostAddress contains 'UK'). The address information is stored in the Contacts table under the PostAddress column. The results should be ordered by the author's name in ascending order.
Required columns:
    • Author
    • Email
    • Address
*//
SELECT a.[Name],c.Email,PostAddress AS [Address]
FROM Authors AS a
JOIN Contacts AS c ON c.Id=a.ContactId
WHERE PostAddress LIKE '%UK%'
ORDER BY a.[Name] ASC

--10
//* 
Your task is to write a query to select details for books of a specific genre -'Fiction', and are sold in libraries located in Denver - their PostAddress contains 'Denver'. Order the result by book title – alphabetically.
Required columns:
    • Author
    • Title
    • Library
    • Library Address
*//
SELECT a.[Name] AS Author,b.Title,l.[Name],PostAddress AS [Library Address]
FROM Books AS b
JOIN Authors AS a ON a.Id=b.AuthorId
JOIN LibrariesBooks AS lb On lb.BookId=b.Id
JOIN Libraries AS l ON l.Id=lb.LibraryId
JOIN Contacts AS c ON c.Id=l.ContactId
JOIN Genres AS g ON g.Id=b.GenreId

WHERE g.[Name] ='Fiction' AND PostAddress LIKE '%Denver%'

ORDER BY b.[Title] ASC

--11
//* 
Create a user-defined function, named udf_AuthorsWithBooks(@name) that receives an author's name.
    • The function will accept an author's name as a parameter
    • It will join the relevant tables to count the total number of books by that author available in all libraries
*//
CREATE OR ALTER FUNCTION  udf_AuthorsWithBooks(@name VARCHAR(50))
RETURNS INT
AS
BEGIN
RETURN
(SELECT COUNT(AuthorID)
FROM Books AS b
JOIN Authors AS a ON a.Id=b.AuthorId
Where a.[Name]=(@name)

)
END

--12
//* 
Create a stored procedure, named usp_SearchByGenre(@genreName) that receives a genre name as a parameter. The procedure must print full information about all books that belong to the specific genre. Order them by book title – alphabetically.
Required columns:
    • Title
    • Year
    • ISBN
    • Author
    • Genre
*//

CREATE OR ALTER PROCEDURE  usp_SearchByGenre(@genreName VARCHAR(50)) 
AS
BEGIN
SELECT b.Title,YearPublished AS [Year],ISBN,a.[Name] AS Author,g.[Name]  AS [Genre]
FROM Books AS b
JOIN Authors AS a ON A.Id=B.AuthorId
JOIN Genres AS g ON g.Id=b.GenreId
WHERE g.[Name]=@genreName
ORDER BY b.Title ASC

END

EXEC usp_SearchByGenre 'Fantasy'