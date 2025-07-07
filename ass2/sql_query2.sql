create database ass2
go 
use ass2

go

create schema company
 go
create table company.department(
dnum int primary key,
dname varchar(50) not null,
managerssn int );
 
go 
create table company.employee(
ssn int primary key,
fname varchar(50) not null,
lname varchar(50) not null,
birthdate date not null,
gender char not null check(gender in('m','f')),
departmentid int not null,
email varchar(100),
foreign key (departmentid) references company.department(dnum)
on delete no action on update cascade);

go
ALTER TABLE company.Department
ADD CONSTRAINT FK_Dept_Manager FOREIGN KEY (ManagerSSN)
    REFERENCES company.Employee(SSN)
    ON DELETE no action
    ON UPDATE no action;

go 



CREATE TABLE company.Project (
    PNumber INT PRIMARY KEY,
    PName VARCHAR(50) NOT NULL,
    PLocation VARCHAR(50));

go

CREATE TABLE Dependent (
    DependentID INT PRIMARY KEY,
    SSN INT NOT NULL,
    DepName VARCHAR(30) NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    BirthDate DATE NOT NULL,
    Relationship VARCHAR(20),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN)
        ON DELETE CASCADE
);
INSERT INTO Department (DNUM, DName) VALUES (1, 'IT');


INSERT INTO Employee (SSN, FName, LName, BirthDate, Gender, DepartmentID)
VALUES (101, 'Nayira', 'Ali', '2005-01-01', 'F', 1);


UPDATE Department SET ManagerSSN = 101 WHERE DNUM = 1;


INSERT INTO Project (PNumber, PName, PLocation, DNUM)
VALUES (1001, 'AI System', 'Cairo', 1);

INSERT INTO Works_On (SSN, PNumber, Hours)
VALUES (101, 1001, 20.5);


INSERT INTO Dependent (DependentID, SSN, DepName, Gender, BirthDate, Relationship)
VALUES (1, 101, 'Sara', 'F', '2015-01-01', 'Daughter');

 