CREATE TABLE Municipality (
	mun_name VARCHAR(50) NOT NULL,
	county VARCHAR(25) NOT NULL,
	PRIMARY KEY (mun_name, county)
);

CREATE TABLE Generalized_GHG_datum (
	mun_name VARCHAR(50) NOT NULL,
	county	VARCHAR(25) NOT NULL,
	year INT NOT NULL,
	em_vehicles INT,
	em_total INT,
	FOREIGN KEY (mun_name, county) REFERENCES Municipality(mun_name, county),
	PRIMARY KEY(mun_name, county, year)
);

CREATE TYPE Emissions_Type AS ENUM ('residential', 'commercial', 'industrial', 'street lighting');

CREATE TABLE General_Emissions (
	em_type Emissions_Type NOT NULL,
	em_electric INT,
	em_ng INT,
	datum_mun VARCHAR(50) NOT NULL,
	datum_cty VARCHAR(50) NOT NULL,
	datum_year INT NOT NULL,
	FOREIGN KEY (datum_mun, datum_cty, datum_year) REFERENCES Generalized_GHG_datum(mun_name, county, year),
    PRIMARY KEY(em_type, datum_mun, datum_cty, datum_year)
);

CREATE TABLE EV_Datum (
	mun_name VARCHAR(50) NOT NULL,
	county VARCHAR(50) NOT NULL,
	year INT NOT NULL,
	num_ev INT,
	num_vehicles INT,
	FOREIGN KEY (mun_name, county) REFERENCES Municipality(mun_name, county),
	PRIMARY KEY(mun_name, county, year)
);


CREATE TABLE Vehicle_GHG_Datum (
	mun_name VARCHAR(50) NOT NULL,
	county	VARCHAR(25) NOT NULL,
	year INT NOT NULL,
	em_total VARCHAR(25),
	mpo VARCHAR(25),
	school_bus VARCHAR(25),
	passenger_car VARCHAR(25),
	light_comm_truck VARCHAR (25),
    motorcycle VARCHAR (25),
    FOREIGN KEY (mun_name, county) REFERENCES Municipality(mun_name, county),
    PRIMARY KEY(mun_name, county, year)
);

CREATE VIEW Mun_EV_Percentage AS 
	SELECT 
		m.mun_name,
		m.county,
		e.year,
		((e.num_ev * 1.0) / e.num_vehicles) AS EV_percentage
	FROM Municipality AS m
	NATURAL JOIN EV_Datum AS e;

CREATE VIEW Mun_EV_Average AS 
	SELECT m.mun_name, m.county, 
	(
		(
			SELECT EV_percentage 
			FROM Mun_EV_Percentage 
			WHERE Mun_name = m.mun_name
				AND County = m.county
			ORDER BY Year DESC LIMIT 1
		) - (
			SELECT EV_percentage 
			FROM Mun_EV_Percentage 
			WHERE Mun_name = m.mun_name 
				AND County = m.county 
			ORDER BY Year ASC LIMIT 1
		)
	) / (MAX(Year) - MIN(Year)) AS Avg_EV_change 
	FROM Municipality AS m 
	NATURAL JOIN Mun_EV_Percentage 
	GROUP BY Mun_name, County;

CREATE VIEW County_EV_Average AS 
	SELECT 
		County, 
		AVG(Avg_EV_change) AS County_avg 
	FROM Mun_EV_Average 
	GROUP BY County;

CREATE VIEW Mun_GHG_Average AS 
	SELECT 
		m.mun_name, 
		m.county, 
		(
			SELECT Em_vehicles 
			FROM Generalized_GHG_Datum 
			WHERE Mun_name = m.mun_name 
				AND County = m.county 
			ORDER BY Year DESC LIMIT 1
		) - (
			SELECT Em_vehicles 
			FROM Generalized_GHG_Datum 
			WHERE Mun_name = m.mun_name 
				AND County = m.county 
			ORDER BY Year ASC LIMIT 1
		) / (MAX(Year) - MIN(Year)) AS Avg_em_vehicle_change,
		(
			SELECT Em_total 
			FROM Generalized_GHG_Datum 
			WHERE Mun_name = m.mun_name 
				AND County = m.county 
			ORDER BY Year DESC LIMIT 1
		) - (
			SELECT Em_total 
			FROM Generalized_GHG_Datum 
			WHERE Mun_name = m.mun_name 
				AND County = m.county 
			ORDER BY Year ASC LIMIT 1
		) / (MAX(Year) - MIN(Year)) AS Avg_em_change 
	FROM Municipality AS m 
	NATURAL JOIN Generalized_GHG_Datum 
	GROUP BY Mun_name, County;

CREATE VIEW County_GHG_Average AS 
	SELECT 
		County, 
		AVG(Avg_em_vehicle_change) AS County_vehicle_avg, 
		AVG(Avg_em_change) AS County_total_avg 
	FROM Mun_GHG_Average 
	GROUP BY County;