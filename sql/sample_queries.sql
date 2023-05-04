SELECT 
    mun_name, 
    county, 
    (
        Avg_EV_change / 
        (1.0 * (
            SELECT MAX(Avg_EV_change) 
            FROM Mun_EV_Average 
            WHERE county = 'Middlesex'
        ))
    ) AS normalized 
FROM Mun_EV_Average 
WHERE county = 'Middlesex' 
ORDER BY Avg_EV_change DESC;

SELECT 
    county, 
    (
        County_avg / 
        (1.0 * (
            SELECT MAX(County_avg) 
            FROM County_EV_Average
        ))
    ) AS normalized 
FROM County_EV_Average 
ORDER BY County_avg DESC;

SELECT 
    mun_name, 
    county, 
    (
        Avg_em_vehicle_change / 
        (1.0 * (
            SELECT MAX(Avg_em_vehicle_change) 
            FROM Mun_GHG_Average 
            WHERE county = 'Middlesex'
        ))
    ) AS normalized 
FROM Mun_GHG_Average 
WHERE county = 'Middlesex' 
ORDER BY Avg_em_vehicle_change DESC;

SELECT 
    mun_name, 
    county, 
    (
        Avg_em_change / 
        (1.0 * (
            SELECT MAX(Avg_em_change) 
            FROM Mun_GHG_Average 
            WHERE county = 'Middlesex'
        ))
    ) AS normalized 
FROM Mun_GHG_Average 
WHERE county = 'Middlesex' 
ORDER BY Avg_em_change DESC;

SELECT 
    county, 
    (
        County_vehicle_avg / 
        (1.0 * (
            SELECT MAX(County_vehicle_avg) 
            FROM County_GHG_Average
        ))
    ) AS normalized 
FROM County_GHG_Average 
ORDER BY County_vehicle_avg DESC;

SELECT 
    county, 
    (
        County_total_avg / 
        (1.0 * (
            SELECT MAX(County_total_avg) 
            FROM County_GHG_Average
        ))
    ) AS normalized 
FROM County_GHG_Average 
ORDER BY County_total_avg DESC;

SELECT * FROM EV_Datum WHERE county = 'Mercer' AND mun_name = 'Ewing township';
SELECT * FROM Generalized_GHG_Datum WHERE county = 'Mercer' AND mun_name = 'Ewing township';
SELECT * FROM Vehicle_GHG_Datum WHERE county = 'Mercer' AND mun_name = 'Ewing township';
