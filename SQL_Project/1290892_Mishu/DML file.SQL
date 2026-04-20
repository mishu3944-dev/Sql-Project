-- Insert into EventUsers
-- =======================
INSERT INTO EventUsers (UserName, Email, PasswordHash, Role)
VALUES 
('Mim', 'mim@example.com', 0x0, 'Admin'),
('Nova', 'nova@example.com', 0x0, 'User'),
('Mahid', 'mahid@example.com', 0x0, 'User');
GO

-- =======================
-- Insert into Categories
-- =======================
INSERT INTO Categories (CategoryName)
VALUES
('Wedding'),
('Birthday'),
('Farewell');
GO


-- Insert into FoodCategories
INSERT INTO FoodCategories (FoodCategoryName)
VALUES
('Vegetarian'),
('Non-Vegetarian'),
('Vegan');
GO

-- Insert into Guests
INSERT INTO Guests (EventID, GuestName, Email, RSVPStatus)
VALUES
(1, 'Pappu', 'pappu@example.com', 'Pending'),
(1, 'Fahad', 'fahad@example.com', 'Confirmed'),
(2, 'Mahi', 'mahi_guest@example.com', 'Pending');
GO

-- =======================
-- Insert into EventDetails
-- =======================
INSERT INTO EventDetails (EventName, UserID, CategoryID, EventDate, Location)
VALUES
('Mim Birthday Bash', 1, 2, '2025-12-01', 'Dhaka'),
('Nova Wedding', 2, 1, '2025-12-15', 'Chattogram'),
('Mahid Farewell', 3, 3, '2026-01-10', 'Coxs Bazar');
GO

-- =======================
-- Insert into FoodPreferences
-- =======================
INSERT INTO FoodPreferences (GuestID, FoodCategoryID, Notes)
VALUES
(1, 1, 'No onions'),
(2, 2, 'Extra spicy'),
(3, 3, 'Gluten free');
GO

-- =======================
-- Insert into LocationPreferences
-- =======================
INSERT INTO LocationPreferences (UserID, PreferredLocation)
VALUES
(1, 'Near park'),
(2, 'Sea view'),
(3, 'City center');
GO

-- =======================
-- Insert into Budget
-- =======================
INSERT INTO Budget (EventID, AllocatedAmount, SpentAmount)
VALUES
(1, 5000.00, 1200.00),
(2, 15000.00, 5000.00),
(3, 8000.00, 3000.00);
GO

-- =======================
-- Insert into Payments
-- =======================
INSERT INTO Payments (EventID, PaidAmount, PaymentMethod, Status)
VALUES
(1, 500.00, 'Cash', 'Completed'),
(2, 2000.00, 'Bank Transfer', 'Pending'),
(3, 1000.00, 'Credit Card', 'Completed');
GO

-- =======================
-- Insert into Invoices
-- =======================
INSERT INTO Invoices (EventID, TotalAmount, DiscountAmount)
VALUES
(1, 2000.00, 100.00),
(2, 5000.00, 500.00),
(3, 3000.00, 0.00);
GO

-- =======================
-- Insert into Logistics
-- =======================
INSERT INTO Logistics (EventID, VendorName, ItemName, Quantity, UnitPrice)
VALUES
(1, 'ABC Catering', 'Tables', 10, 50.00),
(2, 'XYZ Decor', 'Chairs', 50, 20.00),
(3, 'PQR Audio', 'Speakers', 5, 200.00);
GO

-- =======================
-- Insert into Tasks
-- =======================
INSERT INTO Tasks (EventID, TaskName, Priority, Status, DueDate)
VALUES
(1, 'Decorate hall', 'High', 'Pending', '2025-11-30'),
(2, 'Send invitations', 'Medium', 'Completed', '2025-12-01'),
(3, 'Arrange speakers', 'High', 'Pending', '2026-01-05');
GO

-- =======================
-- Insert into Discounts
-- =======================
INSERT INTO Discounts (EventID, DiscountType, DiscountAmount)
VALUES
(1, 'Early Bird', 50.00),
(2, 'Festival Offer', 100.00),
(3, 'No Discount', 0.00);
GO

-- =======================
-- Insert into Schedules
-- =======================
INSERT INTO Schedules (EventID, ActivityName, StartTime, EndTime)
VALUES
(1, 'Cake Cutting', '2025-12-01 19:00', '2025-12-01 19:30'),
(2, 'Wedding Ceremony', '2025-12-15 10:00', '2025-12-15 13:00'),
(3, 'Farewell Party', '2026-01-10 18:00', '2026-01-10 21:00');
GO

-- =======================
-- Insert into Reviews
-- =======================
INSERT INTO Reviews (EventID, GuestID, Rating, Comments)
VALUES
(1, 1, 5, 'Excellent birthday event!'),
(2, 2, 4, 'Beautiful wedding.'),
(3, 3, 3, 'Nice farewell gathering.');
GO
------After Trigger---

-- Insert some EventDetails for testing trigger
INSERT INTO EventDetails (EventName, UserID, CategoryID, EventDate, Location)
VALUES
('Mim Birthday ', 1, 2, '2025-12-01', 'Dhaka'),
('Nova Wedding', 2, 1, '2025-12-15', 'Chattogram'),
('Mahid Farewell', 3, 3, '2026-01-10', 'Coxs Bazar');
GO
-----insted---
INSERT INTO EventDetails (EventName, UserID, CategoryID, EventDate, Location)
VALUES
('Mim Birthday Bash', 1, 2, '2025-12-01', 'Dhaka'),
('Nova Wedding', 2, 1, '2025-12-15', 'Chattogram'),
('Mahid Farewell', 3, 3, '2026-01-10', 'Coxs Bazar');
GO
----funtion---

-- =======================
-- Test fn_GetTotalPayments
-- =======================
Call Scalar Function
SELECT dbo.fn_GetTotalPayments(1) AS TotalPayments_Mim;
- Call Scalar Function
SELECT dbo.fn_GetTotalPayments(2) AS TotalPayments_Nova;
-- Call Multi-Statement Table-Valued Function
SELECT dbo.fn_GetTotalPayments(3) AS TotalPayments_Mahid;
GO
-- =======================
Query Views
-- =======================
SELECT * FROM dbo.fn_EventGuests(1);  -- Guests for Mim Birthday Bash
SELECT * FROM dbo.fn_EventGuests(2);  -- Guests for Nova Wedding
SELECT * FROM dbo.fn_EventGuests(3);  -- Guests for Mahid Farewell
GO
----proedure====
-- Test sp_AddEvent
-- =======================
EXEC sp_AddEvent 'Mim Birthday Bash', 1, 2, '2025-12-01', 'Dhaka';
EXEC sp_AddEvent 'Nova Wedding', 2, 1, '2025-12-15', 'Chattogram';
EXEC sp_AddEvent 'Mahid Farewell', 3, 3, '2026-01-10', 'Coxs Bazar';
GO
EXEC sp_UpdateEvent 
    @EventID = 3, 
    @EventName = 'Mahid Farewell Party', 
    @CategoryID = 3, 
    @EventDate = '2026-01-12', 
    @Location = 'Coxs Bazar Beach';
GO

===DELETE FROM Payments;
DELETE FROM Guests;
DELETE FROM FoodPreferences;
DELETE FROM Budget;
DELETE FROM Invoices;
DELETE FROM Logistics;
DELETE FROM Tasks;
DELETE FROM Discounts;
DELETE FROM Schedules;
DELETE FROM Reviews;
DELETE FROM EventDetails;
GO

=====-- Test sp_AddPayment (max 3)
-- =======================
EXEC sp_AddPayment 1, 500.00, '2025-12-01', 'Cash';
EXEC sp_AddPayment 2, 2000.00, '2025-12-15', 'Bank Transfer';
EXEC sp_AddPayment 3, 1000.00, '2026-01-10', 'Credit Card';
-----------Join-----
--------Inner----
SELECT e.EventName, u.UserName
FROM EventDetails e
INNER JOIN EventUsers u ON e.UserID = u.UserID;
------LEFT JOIN ----
SELECT e.EventName, r.Comments AS ReviewText
FROM EventDetails e
LEFT JOIN Reviews r ON e.EventID = r.EventID;
-----Right------
SELECT g.GuestName, e.EventName
FROM Guests g
RIGHT JOIN EventDetails e ON g.EventID = e.EventID;
SELECT g.GuestName, e.EventName
FROM Guests g
RIGHT JOIN EventDetails e ON g.EventID = e.EventID;
-----Full----
SELECT e.EventName, p.Amount
FROM EventDetails e
FULL OUTER JOIN Payments p ON e.EventID = p.EventID;
------UNION ---
SELECT GuestName AS PersonName, 'Guest' AS PersonType FROM Guests
UNION ALL
SELECT UserName, 'User' FROM EventUsers;
----cross----
--CROSS JOIN
SELECT u.UserName, e.EventName
FROM EventUsers u
CROSS JOIN EventDetails e;

--GROUP BY, HAVING, ROLLUP
SELECT e.EventName, SUM(p.Amount) AS TotalPaid
FROM EventDetails e
JOIN EventPayments p ON e.EventID = p.EventID
GROUP BY ROLLUP(e.EventName)
HAVING SUM(p.Amount) > 5000;

-- --DISTINCT, OFFSET, FETCH

SELECT DISTINCT EventName 
FROM EventDetails;
SELECT EventID, EventName, EventDate
FROM EventDetails
ORDER BY EventDate
OFFSET 5 ROWS FETCH NEXT 3 ROWS ONLY;
GO
--CASE, BETWEEN, LIKE, IS NULL
SELECT EventName,
    CASE 
        WHEN EventDate BETWEEN GETDATE() AND DATEADD(DAY, 7, GETDATE()) THEN 'Happening Soon'
        WHEN EventDate IS NULL THEN 'No Date Fixed'
        ELSE 'Scheduled'
    END AS EventStatus
FROM EventDetails
WHERE EventName LIKE '%Wedding%';
Go
----ANY, ALL----

SELECT EventID, Amount
FROM Payments
WHERE Amount < ANY (
    SELECT Amount 
    FROM Payments 
    WHERE PaymentMethod = 'Card'
);
go

SELECT EventID, PaidAmount
FROM Payments
WHERE PaidAmount < ALL (
    SELECT PaidAmount 
    FROM Payments 
    WHERE PaymentMethod = 'Card'
);
Go
------OVER, AVG, MAX, MIN
SELECT 
    EventID,
    PaidAmount,
    AVG(PaidAmount) OVER (PARTITION BY EventID) AS AvgPaymentPerEvent,
    MAX(PaidAmount) OVER (PARTITION BY EventID) AS MaxPaymentPerEvent,
    MIN(PaidAmount) OVER (PARTITION BY EventID) AS MinPaymentPerEvent
FROM Payments
Go