CREATE DATABASE EmploymentAgencyDB
GO
USE EmploymentAgencyDB

CREATE TABLE Agents
(
	AgentCode uniqueidentifier  NOT NULL ,
	SecondName nvarchar(20)  NOT NULL ,
	Name nvarchar(20)  NOT NULL ,
	Patronymic nvarchar(20)  NOT NULL ,
	PhoneNumber varchar(16)  NULL ,
	Email varchar(40)  NULL ,
	Sex nchar(1)  NULL
)
GO


ALTER TABLE Agents
	ADD CONSTRAINT Agents_AgentCode DEFAULT (NEWID()) FOR AgentCode
GO

ALTER TABLE Agents
	ADD CONSTRAINT AgentsKey PRIMARY KEY  CLUSTERED (AgentCode ASC)
GO


CREATE TABLE Applicants
(
	ApplicantCode uniqueidentifier  NOT NULL ,
	SecondName nvarchar(20) NOT NULL ,
	Name nvarchar(20) NOT NULL ,
	Patronymic nvarchar(20) NOT NULL ,
	ApplicationDate date  NULL ,
	Qualification nvarchar(20)  NULL ,
	Birthday date  NULL ,
	Sex nchar(1)  NOT NULL ,
	RegistrationAddress nvarchar(120)  NULL ,
	PhoneNumber varchar(16)  NULL ,
	JobExperience int  NULL ,
	Email varchar(40)  NULL ,
	EducationCode uniqueidentifier  NULL ,
	PositionCode uniqueidentifier  NULL
)
GO


ALTER TABLE Applicants
	ADD CONSTRAINT Applicants_ApplicationDate DEFAULT (getdate()) FOR ApplicationDate
GO

ALTER TABLE Applicants
	ADD CONSTRAINT Applicants_ApplicationCode DEFAULT (NEWID()) FOR ApplicantCode
GO

ALTER TABLE Applicants
	ADD CONSTRAINT ApplicantsKey PRIMARY KEY  CLUSTERED (ApplicantCode ASC)
GO


CREATE TABLE Deals
(
	DealCode uniqueidentifier  NOT NULL ,
	IssueDate date  NULL ,
	CommissionFee money  NULL ,
	WasPaid bit  NULL ,
	PaymentDate date  NULL ,
	ApplicantCode uniqueidentifier  NULL ,
	VacancyCode uniqueidentifier  NULL ,
	AgentCode uniqueidentifier  NULL
)
GO


ALTER TABLE Deals
	ADD CONSTRAINT Deals_DealCode DEFAULT (NEWID()) FOR DealCode
GO

ALTER TABLE Deals
	ADD CONSTRAINT DealsKey PRIMARY KEY  CLUSTERED (DealCode ASC)
GO


CREATE TABLE Education
(
	EducationCode uniqueidentifier  NOT NULL ,
	EducationDegree nvarchar(20)  NOT NULL ,
	EducationField nvarchar(30)  NOT NULL ,
	Note nvarchar(120)  NULL ,
	EducationalInstitution char(18)  NULL 
)
GO


ALTER TABLE Education
	ADD CONSTRAINT Education_EducationCode DEFAULT (NEWID()) FOR EducationCode
GO

ALTER TABLE Education
	ADD CONSTRAINT EducationKey PRIMARY KEY  CLUSTERED (EducationCode ASC)
GO


CREATE TABLE Employers
(
	EmployerCode uniqueidentifier  NOT NULL ,
	EmployerOrganization nvarchar(60)  NOT NULL ,
	OrganizationAddress nvarchar(120)  NULL ,
	PhoneNumber varchar(16)  NULL ,
	Email varchar(40)  NULL ,
	License nvarchar(20)  NULL
)
GO


ALTER TABLE Employers
	ADD CONSTRAINT Employer_EmployerCode DEFAULT (NEWID()) FOR EmployerCode
GO

ALTER TABLE Employers
	ADD CONSTRAINT EmployersKey PRIMARY KEY  CLUSTERED (EmployerCode ASC)
GO


CREATE TABLE Positions
(
	PositionCode uniqueidentifier  NOT NULL ,
	PositionName nvarchar(60)  NULL ,
	Industry nvarchar(20)  NULL
)
GO


ALTER TABLE Positions
	ADD CONSTRAINT Positions_PositionCode DEFAULT (NEWID()) FOR PositionCode
GO

ALTER TABLE Positions
	ADD CONSTRAINT PositionsKey PRIMARY KEY  CLUSTERED (PositionCode ASC)
GO


CREATE TABLE Vacancies
(
	VacancyCode uniqueidentifier  NOT NULL ,
	PlacementDate date  NULL ,
	Salary money  NULL ,
	Schedule nvarchar(60)  NULL ,
	VacancyStatus nvarchar(60)  NOT NULL ,
	Industry nvarchar(20)  NULL ,
	RequiredEducation nvarchar(60)  NULL ,
	Qualification nvarchar(20)  NULL ,
	EmployerCode uniqueidentifier NULL
)
GO


ALTER TABLE Vacancies
	ADD CONSTRAINT Vacancies_VacancyCode DEFAULT (NEWID()) FOR VacancyCode
GO

ALTER TABLE Vacancies
	ADD CONSTRAINT VacanciesKey PRIMARY KEY  CLUSTERED (VacancyCode ASC)
GO

------------------------------------- Хранимые процедуры ------------------------------------------------

CREATE PROCEDURE SortedInfo @TABLE_NAME nvarchar(40),
                            @SORTBY nvarchar(30) = NULL,
                            @ASCENDING nvarchar(4) = NULL,
                            @SEARCH_FIELD nvarchar(30) = NULL,
                            @SEARCH_VALUE nvarchar(120) = NULL,
                            @SEARCH_N_TYPE bit = 0 AS
DECLARE @SQLStatement nvarchar(512)
SELECT @SQLStatement = 'SELECT * FROM ' + @TABLE_NAME

IF @SORTBY IS NOT NULL
SELECT @SQLStatement = @SQLStatement + ' ORDER BY ' + @SORTBY + ' ' + @ASCENDING

IF @SEARCH_FIELD IS NOT NULL AND @SEARCH_VALUE IS NOT NULL AND @SEARCH_N_TYPE = 1
SELECT @SQLStatement = @SQLStatement + ' WHERE ' + @SEARCH_FIELD + ' = N''' + @SEARCH_VALUE + ''''

IF @SEARCH_FIELD IS NOT NULL AND @SEARCH_VALUE IS NOT NULL AND @SEARCH_N_TYPE = 0
SELECT @SQLStatement = @SQLStatement + ' WHERE ' + @SEARCH_FIELD + ' = ''' + @SEARCH_VALUE + ''''

EXEC(@SQLStatement)
GO

------------------------------------- Представления ------------------------------------------------

CREATE VIEW ApplicantsEducationPosition AS
SELECT Applicants.ApplicantCode AS Code,
        Applicants.SecondName + ' ' + Applicants.Name + ' ' + Applicants.Patronymic AS FIO,
        Applicants.ApplicationDate, Applicants.Birthday, Applicants.Sex,
        Applicants.RegistrationAddress, Applicants.PhoneNumber, Applicants.JobExperience,
        Applicants.Email, Education.EducationDegree, Positions.PositionName
FROM Applicants INNER JOIN Education ON Applicants.EducationCode = Education.EducationCode
INNER JOIN Positions ON Applicants.PositionCode = Positions.PositionCode
GO

------------------------------------- Пользователи ------------------------------------------------

CREATE LOGIN AgentLogin
    WITH PASSWORD = 'AgEnTpAsSwOrD123!';
GO
CREATE USER AgentAccount FOR LOGIN AgentLogin;
GO

GRANT EXECUTE ON SortedInfo TO AgentAccount;
GRANT SELECT ON Applicants TO AgentAccount;
GRANT SELECT ON ApplicantsEducationPosition TO AgentAccount;
GRANT SELECT ON Deals TO AgentAccount;
GRANT SELECT ON Education TO AgentAccount;
GRANT SELECT ON Employers TO AgentAccount;
GRANT SELECT ON Positions TO AgentAccount;
GRANT SELECT ON Vacancies TO AgentAccount;

GRANT INSERT ON Deals TO AgentAccount;
GRANT INSERT ON Applicants TO AgentAccount;
GRANT INSERT ON Education TO AgentAccount;
GRANT INSERT ON Positions TO AgentAccount;
GO
