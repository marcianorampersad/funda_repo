-- Funda Database 

-- Create Funda table 
CREATE OR REPLACE TABLE Funda_House(
GlobalID text PRIMARY KEY,
PublicatieDatum TIMESTAMP WITHOUT TIME ZONE,
Postcode text,
KoopPrijs text,
VolledigeOmschijving text,
SoortWoning text,
CategorieObject text,
Bouwjaar varchar(20),
IndTuin boolean,
PerceelOppervlakte text,
KantoorNaam text,
AantalKamers text,
AantalBadkamers text,
EnergielabelKlasse text,
GlobalID_1 text,
Oppervlakte text,
DatumOndertekening TIMESTAMP WITHOUT TIME ZONE
);

-- Load the data into the table
\copy Funda_House FROM '~/RSL/housing_data.csv' with (format csv, header true, delimiter ',')
;

-- Remove 'NULL' from KoopPrijs, PerceelOppervlakte, AantalKamers, AantalBadkamers, Oppervlakte
UPDATE Funda_House
SET KoopPrijs = '0'
WHERE KoopPrijs = 'NULL'
;

UPDATE Funda_House
SET PerceelOppervlakte = '0'
WHERE PerceelOppervlakte = 'NULL'
;

UPDATE Funda_House
SET AantalKamers = '0'
WHERE AantalKamers = 'NULL'
;

UPDATE Funda_House
SET AantalBadkamers = '0'
WHERE AantalBadkamers = 'NULL'
;

UPDATE Funda_House
SET Oppervlakte = '0'
WHERE Oppervlakte = 'NULL'
;

-- Change from text to interger for KoopPrijs, PerceelOppervlakte, AantalKamers, AantalBadkamers, Oppervlakte

ALTER TABLE Funda_House
ALTER COLUMN KoopPrijs TYPE integer USING (KoopPrijs::integer)
; 

ALTER TABLE Funda_House
ALTER COLUMN PerceelOppervlakte TYPE integer USING (PerceelOppervlakte::integer)
; 

ALTER TABLE Funda_House
ALTER COLUMN AantalKamers TYPE integer USING (AantalKamers::integer)
; 

ALTER TABLE Funda_House
ALTER COLUMN AantalBadkamers TYPE integer USING (AantalBadkamers::integer)
; 

ALTER TABLE Funda_House
ALTER COLUMN Oppervlakte TYPE integer USING (Oppervlakte::integer)
; 

-- Create PostcodeTB
CREATE OR REPLACE TABLE PostcodeTB(
Postcode text PRIMARY KEY,
GemeenteCode text
);

-- Load the data into the table
\copy PostcodeTB FROM '~/RSL/Postcode.csv' with (format csv, header true, delimiter ';');

--Create Gemeente
CREATE TABLE Gemeente(
GemeenteCode text PRIMARY KEY,
ProvincieCode text,
GemeenteNaam text
);

-- Load the data into the table 
\copy Gemeente FROM '~/RSL/Gemeente.csv' with (format csv, header true, delimiter ';');


--Create Provincie
CREATE TABLE Provincie(
ProvincieCode text PRIMARY KEY,
LanddeelCode text,
ProvincieNaam text
);

-- Load the data into the table 
\copy Provincie FROM '~/RSL/Provincie.csv' with (format csv, header true, delimiter ';')
;

--Create Landdeel
CREATE TABLE Landdeel(
LanddeelCode text PRIMARY KEY,
ProvincieNaam text
);

-- Load the data into the table 
\copy Landdeel FROM '~/RSL/Landdeel.csv' with (format csv, header true, delimiter ';')
;

--Create SocialDemographic
CREATE TABLE SocialDemographic(
SoDeID text PRIMARY KEY,
GemeenteCode text,
AantalInwoners int,
Mannen int,
Vrouwn int, 
Jaar0Tot15 int,
Jaar15Tot25 int,
Jaar25Tot45 int,
Jaar45Tot65 int,
Jaar65JOfOuder int,
Bevolkingsdichtheid int,
Woningvoorraad int,
PercentageBewoond int,
GemiddeldeInkomenPerInwoner numeric(3,1),
TotaalDiefstalWoningen int,
AfstandTotHuisartsenpraktijk numeric(2,1),
AfstandTotGroteSupermarkt numeric(2,1),
AfstandTotKinderdagverblijf numeric(2,1),
AfstandTotSchool numeric(2,1),
AfstandTotRestaurant numeric(2,1),
AfstandTotTreinstation numeric(3,1)
);

-- Load the data into the table 
\copy SocialDemographic FROM '~/RSL/Algemeen.csv' with (format csv, header true, delimiter ';')
;

-- Set the Foreign Keys for the tables

/*
DELETE FROM Funda_House -- Delete the postcode from the Funda data that is incomplete (only 4 instead of 6)
WHERE length(postcode)<6
;

DELETE FROM Funda_House -- Delete the postcode from the Funda data because it is a postbus and not a house
WHERE postcode = '2800AN';

DELETE FROM Funda_House -- Delete the postcode from the Funda data because it is not a real postcode
WHERE postcode = '8943EZ';

ALTER TABLE Funda_House -- Error missing postcode included in Funda data 
ADD CONSTRAINT Postcode
FOREIGN KEY (Postcode) 
REFERENCES PostcodeTB(Postcode)
;
*/


ALTER TABLE PostcodeTB 
ADD CONSTRAINT GemeenteCode
FOREIGN KEY (GemeenteCode) 
REFERENCES Gemeente(GemeenteCode)
;

ALTER TABLE Gemeente 
ADD CONSTRAINT ProvincieCode
FOREIGN KEY (ProvincieCode) 
REFERENCES Provincie(ProvincieCode)
;

ALTER TABLE Provincie 
ADD CONSTRAINT LanddeelCode
FOREIGN KEY (LanddeelCode) 
REFERENCES Landdeel(LanddeelCode)
;

ALTER TABLE SocialDemographic
ADD CONSTRAINT GemeenteCode
FOREIGN KEY (GemeenteCode) 
REFERENCES Gemeente(GemeenteCode)
;


-- Find values from two tables
SELECT
	AantalInwoners,
	Bevolkingsdichtheid,
	GemiddeldeInkomenPerInwoner,
	GemeenteNaam
FROM
	Gemeente
INNER JOIN SocialDemographic USING(GemeenteCode)
ORDER BY GemiddeldeInkomenPerInwoner
;

-- Find values from three tables
SELECT
	AantalInwoners,
	Bevolkingsdichtheid,
	GemeenteNaam,
	ProvincieNaam
FROM
	Gemeente
INNER JOIN SocialDemographic 
    ON SocialDemographic.GemeenteCode = Gemeente.GemeenteCode
INNER JOIN Provincie 
    ON Provincie.ProvincieCode = Gemeente.ProvincieCode
ORDER BY AantalInwoners
;

-- Find values from four tables / ERROR
SELECT
	KoopPrijs,
	AantalKamers,
	Postcode,
	GemeenteNaam,
	ProvincieNaam
FROM
	Gemeente
INNER JOIN Funda_House 
    ON Funda_House.Postcode = PostcodeTB.Postcode
INNER JOIN PostcodeTB 
    ON PostcodeTB.GemeenteCode = Gemeente.GemeenteCode
INNER JOIN Provincie 
    ON Provincie.ProvincieCode = Gemeente.ProvincieCode
ORDER BY KoopPrijs
;
