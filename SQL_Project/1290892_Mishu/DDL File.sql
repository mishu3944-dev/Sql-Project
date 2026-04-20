
Use master
Go

Declare @data_path Nvarchar (256);

Set @data_path =(Select SUBSTRING(physical_name,1,CHARINDEX(N'master.mdf',LOWER(physical_name))-1)
From master.sys.master_files
Where database_id=1 And file_id=1);

Exec('Create Database EventManagementDB
On Primary (Name= EventManagementDB_Data_1, Filename= '''+ @data_path +'EventManagementDB_1.mdf'', Size=25mb, maxsize=100mb, Filegrowth=5%)
Log On (Name= EventmanagementDB_Log_1, Filename= '''+ @data_path +'EventManagementDB_Log_1.ldf'', Size=2mb, Maxsize=50mb, Filegrowth=1mb)
'
);
Go
----Drop Databas--
Drop Database EventManagementDB
Go

---Creat Database--
Create Database EventManagementDB
Go

CREATE TABLE EventUsers (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    UserName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) UNIQUE NOT NULL,
    PasswordHash VARBINARY(MAX),
    Role VARCHAR(50) DEFAULT 'Admin',
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
GO


CREATE TABLE Categories 
(
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(100) NOT NULL
);
GO


CREATE TABLE FoodCategories
(
    FoodCategoryID INT PRIMARY KEY IDENTITY(1,1),
    FoodCategoryName VARCHAR(50) NOT NULL
);
GO


CREATE TABLE FoodPreferences
(
    FoodPreferenceID INT PRIMARY KEY IDENTITY(1,1),
    GuestID INT, -- FK to Guests later
    FoodCategoryID INT FOREIGN KEY REFERENCES FoodCategories(FoodCategoryID),
    Notes VARCHAR(200)
);
GO


CREATE TABLE LocationPreferences 
(
    LocationPreferenceID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES EventUsers(UserID),
    PreferredLocation VARCHAR(200)
);
GO


CREATE TABLE EventDetails 
(
    EventID INT PRIMARY KEY IDENTITY(1,1),
    EventName VARCHAR(150) NOT NULL,
    UserID INT FOREIGN KEY REFERENCES eventUsers(UserID),
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    EventDate DATE NOT NULL,
    Location VARCHAR(200),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO


CREATE TABLE Guests 
(
    GuestID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT FOREIGN KEY REFERENCES EventDetails(EventID),
    GuestName VARCHAR(100) NOT NULL,
    Email VARCHAR(150),
    RSVPStatus VARCHAR(20) DEFAULT 'Pending'
);
GO


CREATE TABLE Budget 
(
    BudgetID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT FOREIGN KEY REFERENCES EventDetails(EventID),
    AllocatedAmount DECIMAL(12,2),
    SpentAmount DECIMAL(12,2) DEFAULT 0.00
);
GO


CREATE TABLE Payments 
(
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT FOREIGN KEY REFERENCES EventDetails(EventID),
    PaidAmount DECIMAL(10,2) NOT NULL,
    PaymentDate DATE DEFAULT GETDATE(),
    PaymentMethod VARCHAR(50),
    Status VARCHAR(20) DEFAULT 'Pending'
);
GO



CREATE TABLE Invoices
(
    InvoiceID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT FOREIGN KEY REFERENCES EventDetails(EventID),
    TotalAmount DECIMAL(12,2),
    DiscountAmount DECIMAL(12,2) DEFAULT 0.00,
    FinalAmount AS (TotalAmount - DiscountAmount)
);
GO


CREATE TABLE Logistics 
(
    LogisticID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT FOREIGN KEY REFERENCES EventDetails(EventID),
    VendorName VARCHAR(100),
    ItemName VARCHAR(100),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    Status VARCHAR(50) DEFAULT 'Pending'
);
GO


CREATE TABLE Tasks
(
    TaskID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT FOREIGN KEY REFERENCES EventDetails(EventID),
    TaskName VARCHAR(150),
    Priority VARCHAR(20) DEFAULT 'Normal',
    Status VARCHAR(20) DEFAULT 'Pending',
    DueDate DATE
);
GO


CREATE TABLE Discounts 
(
    DiscountID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT FOREIGN KEY REFERENCES EventDetails(EventID),
    DiscountType VARCHAR(50),
    DiscountAmount DECIMAL(10,2)
);
GO


CREATE TABLE Schedules 
(
    ScheduleID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT FOREIGN KEY REFERENCES EventDetails(EventID),
    ActivityName VARCHAR(150),
    StartTime DATETIME,
    EndTime DATETIME
);
GO

CREATE TABLE Reviews
(
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT FOREIGN KEY REFERENCES EventDetails(EventID),
    GuestID INT FOREIGN KEY REFERENCES Guests(GuestID),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments VARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- =======================
-- Indexes
-- =======================
CREATE INDEX IX_EventDetails_EventDate ON EventDetails(EventDate);
CREATE INDEX IX_Guests_RSVPStatus ON Guests(RSVPStatus);
GO
-- Trigger: Auto Log First Event for Users
-- =======================
            ---After---
CREATE TABLE UserEventLog 
(
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT,
    FirstEventID INT,
    FirstEventDate DATE
);
GO
CREATE TRIGGER trg_AfterInsertEvent
ON EventDetails
AFTER INSERT
AS
BEGIN
    INSERT INTO UserEventLog (UserID, FirstEventID, FirstEventDate)
    SELECT i.UserID, i.EventID, i.EventDate
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT 1 
        FROM UserEventLog u
        WHERE u.UserID = i.UserID
    );
END;
GO

---insted trigger---
CREATE TRIGGER trg_PreventDeleteEvent
ON EventDetails
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Cannot delete event: Payments exist.';
        RETURN;
       
  END
  GO

-- =======================
      ---Funtion-----
-- =======================
-- Sample Scalar Function: Total Payments by Event
-- =======================
CREATE FUNCTION fn_GetTotalPayments(@EventID INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @Total DECIMAL(12,2);
    SELECT @Total = SUM(PaidAmount) FROM Payments WHERE EventID = @EventID;
    RETURN ISNULL(@Total,0);
END;
GO

-- Inline Table-Valued Function: Guests for an Event
CREATE FUNCTION fn_EventGuests(@EventID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT GuestID, GuestName, Email, RSVPStatus
    FROM Guests
    WHERE EventID = @EventID
);
GO
-- Multi-Statement Table-Valued Function: Event Budget Summary
CREATE FUNCTION fn_BudgetSummary(@EventID INT)
RETURNS @Summary TABLE
(
    AllocatedAmount DECIMAL(12,2),
    SpentAmount DECIMAL(12,2),
    RemainingAmount DECIMAL(12,2)
)
AS
BEGIN
    INSERT INTO @Summary
    SELECT AllocatedAmount, SpentAmount, AllocatedAmount - SpentAmount
    FROM Budget
    WHERE EventID = @EventID;

    RETURN;
END;
GO
-- =======================
-- Sample Stored Procedure: Add Event
-- =======================
CREATE PROCEDURE sp_AddEvent
    @EventName VARCHAR(150),
    @UserID INT,
    @CategoryID INT,
    @EventDate DATE,
    @Location VARCHAR(200)
AS
BEGIN
    INSERT INTO EventDetails (EventName, UserID, CategoryID, EventDate, Location)
    VALUES (@EventName, @UserID, @CategoryID, @EventDate, @Location);
END;
GO

-- =======================
-- Stored Procedure: Update Event
-- =======================
CREATE PROCEDURE sp_UpdateEvent
    @EventID INT,
    @EventName VARCHAR(150),
    @CategoryID INT,
    @EventDate DATE,
    @Location VARCHAR(200)
AS
BEGIN
    UPDATE EventDetails
    SET EventName = @EventName,
        CategoryID = @CategoryID,
        EventDate = @EventDate,
        Location = @Location
    WHERE EventID = @EventID;
END;
GO

-- =======================
-- Stored Procedure: Delete Event
-- =======================
CREATE PROCEDURE sp_DeleteEvent
    @EventID INT
AS
BEGIN
    -- Delete child tables first to avoid FK conflict
    DELETE FROM Guests WHERE EventID = @EventID;
    DELETE FROM FoodPreferences WHERE GuestID IN (SELECT GuestID FROM Guests WHERE EventID = @EventID);
    DELETE FROM Budget WHERE EventID = @EventID;
    DELETE FROM Payments WHERE EventID = @EventID;
    DELETE FROM Invoices WHERE EventID = @EventID;
    DELETE FROM Logistics WHERE EventID = @EventID;
    DELETE FROM Tasks WHERE EventID = @EventID;
    DELETE FROM Discounts WHERE EventID = @EventID;
    DELETE FROM Schedules WHERE EventID = @EventID;
    DELETE FROM Reviews WHERE EventID = @EventID;

    -- Then delete the event
    DELETE FROM EventDetails WHERE EventID = @EventID;
END;
GO

-- =======================
-- Stored Procedure: Add Payment
-- =======================
CREATE PROCEDURE sp_AddPayment
    @EventID INT,
    @PaidAmount DECIMAL(18,2),
    @PaymentDate DATE,
    @PaymentMethod NVARCHAR(50)
AS
BEGIN
    INSERT INTO Payments (EventID, PaidAmount, PaymentDate, PaymentMethod, Status)
    VALUES (@EventID, @PaidAmount, @PaymentDate, @PaymentMethod, 'Pending');
END;
GO

-- =======================
-- Collation Example
-- =======================
ALTER TABLE EventDetails
ALTER COLUMN EventName VARCHAR(150) COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

-- =======================
-- Sparse Column Example
-- =======================
ALTER TABLE Reviews
ADD ExtraNotes VARCHAR(200) SPARSE NULL;
GO

-- =======================
-- Varbinary Example
-- =======================
ALTER TABLE EventDetails
ADD EventImage VARBINARY(MAX);
GO

-- =======================
-- Transaction Example
-- =======================
BEGIN TRAN SaveEvent
    INSERT INTO EventDetails (EventName, UserID, CategoryID, EventDate)
    VALUES ('Sample Event', 1, 1, GETDATE());
    IF @@ROWCOUNT = 1
        COMMIT TRAN SaveEvent;
    ELSE
        ROLLBACK TRAN SaveEvent;
GO

-- =======================
-- IF...ELSE & PRINT Example
-- =======================
CREATE PROCEDURE sp_CheckBudget
    @EventID INT
AS
BEGIN
    DECLARE @Budget DECIMAL(12,2);
    SELECT @Budget = AllocatedAmount - SpentAmount
    FROM Budget
    WHERE EventID = @EventID;

    IF @Budget < 1000
        PRINT 'Low Budget';
    ELSE
        PRINT 'Budget OK';
END;
GO
-----View: Event Review Summary (Schema-Bounding)
CREATE VIEW dbo.vEventReviewSummary
WITH SCHEMABINDING
AS
SELECT e.EventID, e.EventName, COUNT_BIG(r.ReviewID) AS TotalReviews
FROM dbo.EventDetails e
INNER JOIN dbo.Reviews r ON e.EventID = r.EventID
GROUP BY e.EventID, e.EventName;
GO
-------- ==========================================
-- Stored Procedure: Event Review Summary (Encrypted)
-- ==========================================
CREATE PROCEDURE dbo.sp_GetEventReviewSummary
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    SELECT e.EventName, COUNT(r.ReviewID) AS TotalReviews
    FROM dbo.EventDetails e
    INNER JOIN dbo.Reviews r ON e.EventID = r.EventID
    GROUP BY e.EventName;
END;
GO