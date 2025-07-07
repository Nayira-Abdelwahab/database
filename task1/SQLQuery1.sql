
UPDATE DEPARTMENT SET MGRSSN = 1001 WHERE DName = 'HR';
UPDATE DEPARTMENT SET MGRSSN = 1002 WHERE DName = 'IT';
UPDATE DEPARTMENT SET MGRSSN = 1004 WHERE DName = 'Finance';


INSERT INTO EMPLOYEE (Fname, Lname, BirthDate, SuperSSN, DNO)
VALUES
('Sara', 'Omar', '1992-03-22', 1010, 6),
('Nour', 'Kamal', '1988-07-10', 1010, 6),
('Tarek', 'Yehia', '1985-01-30', 1010, 7),
('Laila', 'Fathy', '1995-11-05', 1010, 5);

INSERT INTO EMPLOYEE (Fname, Lname, BirthDate,  SuperSSN, DNO)
VALUES ('Ali', 'Hassan', '1990-05-15', NULL, 5);  







SELECT * FROM EMPLOYEE;