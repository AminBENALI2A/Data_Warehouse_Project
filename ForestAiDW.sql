-- Create the database
CREATE DATABASE ForestAiDW;
GO

-- Use the newly created database
USE ForestAiDW;
GO

-- Create Time Dimension table
CREATE TABLE TimeDimension (
    DateID INT PRIMARY KEY IDENTITY(1,1),
    Date DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    Day INT NOT NULL
);
GO


-- Create Location Dimension table
CREATE TABLE LocationDimension (
    LocationID INT PRIMARY KEY IDENTITY(1,1),
    Country NVARCHAR(100),
    Region NVARCHAR(100),
    ForestArea NVARCHAR(100),
    PlotID NVARCHAR(100)
);
GO

-- Create Metric Dimension table
CREATE TABLE MetricDimension (
    MetricID INT PRIMARY KEY IDENTITY(1,1),
    MetricName NVARCHAR(100),
    MetricUnit NVARCHAR(50)
);
GO

-- Create Tree Species Dimension table
CREATE TABLE TreeSpeciesDimension (
    SpeciesID INT PRIMARY KEY IDENTITY(1,1),
    SpeciesName NVARCHAR(100)
);
GO

-- Create Model Dimension table
CREATE TABLE ModelDimension (
    ModelID INT PRIMARY KEY IDENTITY(1,1),
    ModelName NVARCHAR(100),
    ModelVersion NVARCHAR(50),
    Description NVARCHAR(255)
);
GO

-- Create Client Dimension table
CREATE TABLE ClientDimension (
    ClientID INT PRIMARY KEY IDENTITY(1,1),
    ClientName NVARCHAR(100),
    ClientRegion NVARCHAR(100),
    ContactInformation NVARCHAR(255)
);
GO



-----------------------------------populating


-- Insert sample data into Tree Species Dimension
INSERT INTO TreeSpeciesDimension (SpeciesName)
VALUES 
    ('Pine'),
    ('Spruce'),
    ('Deciduous');
GO



-- Insert sample data into Client Dimension
INSERT INTO ClientDimension (ClientName, ClientRegion, ContactInformation)
VALUES 
    ('ForestAI Client 1', 'North America', 'contact@forestai.com');
GO



-- Insert sample data into Model Dimension
INSERT INTO ModelDimension (ModelName, ModelVersion, Description)
VALUES 
    ('Model A', 'v1.0', 'Initial version with basic features'),
    ('Model B', 'v1.1', 'Enhanced version with improved accuracy'),
    ('Model C', 'v2.0', 'Advanced version with new algorithms and features');
GO



INSERT INTO MetricDimension (MetricName, MetricUnit)
VALUES 
    ('Volume', 'm³/ha'),
    ('Timber', 'm³/ha'),
    ('Average Height', 'm'),
    ('Basal Area', 'm²/ha'),
    ('Average DBH', 'cm')
GO



-- Insert sample data into Location Dimension for Greenwood Forest
INSERT INTO LocationDimension (Country, Region, ForestArea, PlotID)
VALUES 
    ('United States', 'Pacific Northwest', 'Greenwood Forest', 'Plot001'),
    ('United States', 'Pacific Northwest', 'Greenwood Forest', 'Plot002'),
    ('United States', 'Pacific Northwest', 'Greenwood Forest', 'Plot003');
GO


-- Populate the TimeDimension table with one row for a specific date
DECLARE @StartDate DATE = '2022-01-02';
DECLARE @EndDate DATE = '2023-01-01'; -- You can adjust the end date as needed

-- Create Date Dimension table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TimeDimension')
BEGIN
    CREATE TABLE TimeDimension (
        DateID INT PRIMARY KEY,
        [Date] DATE,
        [Year] INT,
        [Quarter] INT,
        [Month] INT,
        [Day] INT
    );
END;

-- Delete existing data in Date Dimension table
TRUNCATE TABLE TimeDimension;

-- Insert data into Date Dimension
WITH DateCTE AS (
    SELECT
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, @StartDate) AS [Date]
    FROM
        sys.columns c1
    CROSS JOIN
        sys.columns c2
)
INSERT INTO TimeDimension ([Date], [Year], [Quarter], [Month], [Day])
SELECT
    [Date],
    YEAR([Date]),
    DATEPART(QUARTER, [Date]),
    MONTH([Date]),
    DAY([Date])
FROM
    DateCTE
WHERE
    [Date] <= @EndDate;


---------------------Fact Tables

CREATE TABLE Models_Facts (
    Fact_Id INT PRIMARY KEY IDENTITY(1,1),
    Model_Id INT,
    Location_Id INT,
    Tree_Species_Id INT,
    Metric_Id INT,
    Time_Id INT,
    Predicted_Value FLOAT,
    CONSTRAINT FK_Models_Facts_Model_Id FOREIGN KEY (Model_Id) REFERENCES ModelDimension(ModelID),
    CONSTRAINT FK_Models_Facts_Location_Id FOREIGN KEY (Location_Id) REFERENCES LocationDimension(LocationID),
    CONSTRAINT FK_Models_Facts_Tree_Species_Id FOREIGN KEY (Tree_Species_Id) REFERENCES TreeSpeciesDimension(SpeciesID),
    CONSTRAINT FK_Models_Facts_Metric_Id FOREIGN KEY (Metric_Id) REFERENCES MetricDimension(MetricID),
    CONSTRAINT FK_Models_Facts_Time_Id FOREIGN KEY (Time_Id) REFERENCES TimeDimension(DateID)
);


CREATE TABLE Ground_Truth_Facts (
    Fact_Id INT PRIMARY KEY IDENTITY(1,1),
    Location_Id INT,
    Tree_Species_Id INT,
    Metric_Id INT,
    Time_Id INT,
    True_Values FLOAT,
    CONSTRAINT FK_Ground_Truth_Facts_Location_Id FOREIGN KEY (Location_Id) REFERENCES LocationDimension(LocationID),
    CONSTRAINT FK_Ground_Truth_Facts_Tree_Species_Id FOREIGN KEY (Tree_Species_Id) REFERENCES TreeSpeciesDimension(SpeciesID),
    CONSTRAINT FK_Ground_Truth_Facts_Metric_Id FOREIGN KEY (Metric_Id) REFERENCES MetricDimension(MetricID),
    CONSTRAINT FK_Ground_Truth_Facts_Time_Id FOREIGN KEY (Time_Id) REFERENCES TimeDimension(DateID)
);



CREATE TABLE Client_Facts (
    Fact_Id INT PRIMARY KEY IDENTITY(1,1),
    Client_Id INT,
    Location_Id INT,
    Tree_Species_Id INT,
    Metric_Id INT,
    Time_Id INT,
    Client_Estimation FLOAT,
    CONSTRAINT FK_Client_Facts_Client_Id FOREIGN KEY (Client_Id) REFERENCES ClientDimension(ClientID),
    CONSTRAINT FK_Client_Facts_Location_Id FOREIGN KEY (Location_Id) REFERENCES LocationDimension(LocationID),
    CONSTRAINT FK_Client_Facts_Tree_Species_Id FOREIGN KEY (Tree_Species_Id) REFERENCES TreeSpeciesDimension(SpeciesID),
    CONSTRAINT FK_Client_Facts_Metric_Id FOREIGN KEY (Metric_Id) REFERENCES MetricDimension(MetricID),
    CONSTRAINT FK_Client_Facts_Time_Id FOREIGN KEY (Time_Id) REFERENCES TimeDimension(DateID)
);



------------------------------------Populate the Facts:

-- Populate the Models_Facts table with unique random predicted values
INSERT INTO Models_Facts (Model_Id, Location_Id, Tree_Species_Id, Metric_Id, Time_Id, Predicted_Value)
SELECT 
    m.ModelID,
    l.LocationID,
    ts.SpeciesID,
    mt.MetricID,
    t.DateID,
    FLOOR(RAND(CHECKSUM(NEWID())) * 100) -- Generate a unique random predicted value between 0 and 1000 for each row
FROM 
    ModelDimension m
CROSS JOIN 
    LocationDimension l
CROSS JOIN 
    TreeSpeciesDimension ts
CROSS JOIN 
    MetricDimension mt
CROSS JOIN 
    TimeDimension t;

-- Populate the Ground_Truth_Facts table with unique random true values
INSERT INTO Ground_Truth_Facts (Location_Id, Tree_Species_Id, Metric_Id, Time_Id, True_Values)
SELECT 
    l.LocationID,
    ts.SpeciesID,
    mt.MetricID,
    t.DateID,
    FLOOR(RAND(CHECKSUM(NEWID())) * 100) -- Generate a unique random true value between 0 and 1000 for each row
FROM 
    LocationDimension l
CROSS JOIN 
    TreeSpeciesDimension ts
CROSS JOIN 
    MetricDimension mt
CROSS JOIN 
    TimeDimension t;

-- Populate the Client_Facts table with unique random client estimations
INSERT INTO Client_Facts (Client_Id, Location_Id, Tree_Species_Id, Metric_Id, Time_Id, Client_Estimation)
SELECT 
    c.ClientID,
    l.LocationID,
    ts.SpeciesID,
    mt.MetricID,
    t.DateID,
    FLOOR(RAND(CHECKSUM(NEWID())) * 100) -- Generate a unique random client estimation value between 0 and 1000 for each row
FROM 
    ClientDimension c
CROSS JOIN 
    LocationDimension l
CROSS JOIN 
    TreeSpeciesDimension ts
CROSS JOIN 
    MetricDimension mt
CROSS JOIN 
    TimeDimension t;



-- for slowly changing dimension
USE ForestAiDW;
GO

CREATE SCHEMA ModelHistory;
GO

CREATE TABLE ModelHistory.ModelDimension (
    ModelID INT IDENTITY(1,1) PRIMARY KEY,
    ModelName NVARCHAR(50),
    ModelVersion NVARCHAR(10),
    Description NVARCHAR(255),
    IsCurrent BIT
);
GO



INSERT INTO ModelHistory.ModelDimension (ModelName, ModelVersion, Description)
VALUES 
    ('Model A', 'v1.5', 'Initial version with basic features', 1),
    ('Model B', 'v1.8', 'Enhanced version with improved accuracy', 1),
    ('Model C', 'v2.9', 'Advanced version with new algorithms and features', 1);
GO





