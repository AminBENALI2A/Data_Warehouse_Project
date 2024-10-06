-- Create the datamart database
CREATE DATABASE DatamartForestAI;
GO

-- Use the newly created database
USE DatamartForestAI;
GO

-- Create Time Dimension table
CREATE TABLE TimeDimension (
    TimeID INT PRIMARY KEY IDENTITY(1,1),
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
    Country NVARCHAR(100) NOT NULL,
    Region NVARCHAR(100) NOT NULL,
    ForestArea NVARCHAR(100) NOT NULL,
    PlotID NVARCHAR(100) NOT NULL
);
GO

-- Create Metric Dimension table
CREATE TABLE MetricDimension (
    MetricID INT PRIMARY KEY IDENTITY(1,1),
    MetricName NVARCHAR(100) NOT NULL,
    MetricUnit NVARCHAR(50) NOT NULL
);
GO

-- Create Tree Species Dimension table
CREATE TABLE TreeSpeciesDimension (
    SpeciesID INT PRIMARY KEY IDENTITY(1,1),
    SpeciesName NVARCHAR(100) NOT NULL
);
GO

-- Create Model Dimension table
CREATE TABLE ModelDimension (
    ModelID INT PRIMARY KEY IDENTITY(1,1),
    ModelName NVARCHAR(100) NOT NULL,
    ModelVersion NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255)
);
GO

-- Create Client Dimension table
CREATE TABLE ClientDimension (
    ClientID INT PRIMARY KEY IDENTITY(1,1),
    ClientName NVARCHAR(100) NOT NULL,
    ClientRegion NVARCHAR(100) NOT NULL,
    ContactInformation NVARCHAR(255)
);
GO

-- Create Model Predictions fact table
CREATE TABLE ModelPredictions (
    PredictionID INT PRIMARY KEY IDENTITY(1,1),
    ModelID INT,
    LocationID INT,
    SpeciesID INT,
    MetricID INT,
    TimeID INT,
    PredictedValue FLOAT,
    FOREIGN KEY (ModelID) REFERENCES ModelDimension(ModelID),
    FOREIGN KEY (LocationID) REFERENCES LocationDimension(LocationID),
    FOREIGN KEY (SpeciesID) REFERENCES TreeSpeciesDimension(SpeciesID),
    FOREIGN KEY (MetricID) REFERENCES MetricDimension(MetricID),
    FOREIGN KEY (TimeID) REFERENCES TimeDimension(TimeID)
);
GO

-- Create Ground Truth fact table
CREATE TABLE GroundTruth (
    GroundTruthID INT PRIMARY KEY IDENTITY(1,1),
    LocationID INT,
    SpeciesID INT,
    MetricID INT,
    TimeID INT,
    TrueValue FLOAT,
    FOREIGN KEY (LocationID) REFERENCES LocationDimension(LocationID),
    FOREIGN KEY (SpeciesID) REFERENCES TreeSpeciesDimension(SpeciesID),
    FOREIGN KEY (MetricID) REFERENCES MetricDimension(MetricID),
    FOREIGN KEY (TimeID) REFERENCES TimeDimension(TimeID)
);
GO

-- Create Client Estimations fact table
CREATE TABLE ClientEstimations (
    EstimationID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT,
    LocationID INT,
    SpeciesID INT,
    MetricID INT,
    TimeID INT,
    ClientEstimation FLOAT,
    FOREIGN KEY (ClientID) REFERENCES ClientDimension(ClientID),
    FOREIGN KEY (LocationID) REFERENCES LocationDimension(LocationID),
    FOREIGN KEY (SpeciesID) REFERENCES TreeSpeciesDimension(SpeciesID),
    FOREIGN KEY (MetricID) REFERENCES MetricDimension(MetricID),
    FOREIGN KEY (TimeID) REFERENCES TimeDimension(TimeID)
);
GO

-- Add Source_Id column to TimeDimension table
ALTER TABLE TimeDimension
ADD Source_Id INT;
GO

-- Add Source_Id column to LocationDimension table
ALTER TABLE LocationDimension
ADD Source_Id INT;
GO

-- Add Source_Id column to MetricDimension table
ALTER TABLE MetricDimension
ADD Source_Id INT;
GO

-- Add Source_Id column to TreeSpeciesDimension table
ALTER TABLE TreeSpeciesDimension
ADD Source_Id INT;
GO

-- Add Source_Id column to ModelDimension table
ALTER TABLE ModelDimension
ADD Source_Id INT;
GO

-- Add Source_Id column to ClientDimension table
ALTER TABLE ClientDimension
ADD Source_Id INT;
GO

-- Add Source_Id column to ModelPredictions table
ALTER TABLE ModelPredictions
ADD Source_Id INT;
GO

-- Add Source_Id column to GroundTruth table
ALTER TABLE GroundTruth
ADD Source_Id INT;
GO

-- Add Source_Id column to ClientEstimations table
ALTER TABLE ClientEstimations
ADD Source_Id INT;
GO


-- for slowly changing dimension

ALTER TABLE dbo.ModelDimension
ADD IsCurrent BIT;
GO


	-- Select statements to verify the creation of tables (optional)
SELECT * FROM TimeDimension;
SELECT * FROM LocationDimension;
SELECT * FROM MetricDimension;
SELECT * FROM TreeSpeciesDimension;
SELECT * FROM ModelDimension;
SELECT * FROM ClientDimension;
SELECT * FROM ModelPredictions;
SELECT * FROM GroundTruth;
SELECT * FROM ClientEstimations;

