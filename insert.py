import csv


def numeric(string):
    return ''.join(digit for digit in string if digit.isdigit() or digit == '.') or 'NULL'


with open('data/ghg_general.csv') as inp:
    with open('sql/insert_mun.sql', 'w') as mun, open('sql/insert_ghg.sql', 'w') as ghg:
        star = False
        f = csv.reader(inp)
        for i, line in enumerate(f):
            if line[0] == 'Municipality':
                star = True
                continue
            if not star or not line:
                continue
            mun_name = line[0]
            if len(mun_name.split(' ')) > 1:
                mun_name = ' '.join(mun_name.split(
                    ' ')[:-1]) + ' ' + mun_name.split(' ')[-1].lower()
            if i % 2 == 0:
                mun.write(
                    f"INSERT INTO Municipality VALUES ('{mun_name}', '{line[1]}');\n")
            ghg.write(
                f"""INSERT INTO Generalized_GHG_Datum (mun_name, county, year, em_vehicles, em_total) VALUES ('{mun_name.strip()}', '{line[1].strip()}', {line[3]}, {numeric(line[-3])}, {numeric(line[-2])});\n""")
            ghg.write(
                f"""INSERT INTO General_Emissions (datum_mun, datum_cty, datum_year, em_type, em_electric, em_ng) VALUES 
                            ('{mun_name.strip()}', '{line[1].strip()}', {line[3]}, 'residential', {numeric(line[4])}, {numeric(line[8])}),
                            ('{mun_name.strip()}', '{line[1].strip()}', {line[3]}, 'commercial', {numeric(line[5])}, {numeric(line[9])}),
                            ('{mun_name.strip()}', '{line[1].strip()}', {line[3]}, 'street lighting', {numeric(line[7])}, {numeric(line[11])}),
                            ('{mun_name.strip()}', '{line[1].strip()}', {line[3]}, 'industrial', {numeric(line[6])}, {numeric(line[10])});\n""")


with open('data/ghg_vehicles.csv') as inp:
    with open('sql/insert_vehicles.sql', 'w') as v:
        star = False
        f = csv.reader(inp)
        for line in f:
            if line[0].startswith('Municipality'):
                star = True
                continue
            if not star:
                continue
            mun_name = line[0]
            if len(mun_name.split(' ')) > 1:
                mun_name = ' '.join(mun_name.split(
                    ' ')[:-1]) + ' ' + mun_name.split(' ')[-1].lower()
            v.write(f"""INSERT INTO Vehicle_GHG_Datum (mun_name, county, year, em_total, mpo, school_bus, passenger_car, light_comm_truck, motorcycle)
            VALUES ('{mun_name.strip()}', '{line[1].strip()}', {line[3]}, {numeric(line[-1])}, '{line[2]}', {numeric(line[-5])}, {numeric(line[10])}, {numeric(line[7])}, {numeric(line[9])});\n""")


with open('data/ev.csv') as inp:
    with open('sql/insert_ev.sql', 'w') as v:
        star = False
        f = csv.reader(inp)
        for line in f:
            if line[0].startswith('Municipality'):
                star = True
                continue
            if not star:
                continue
            mun_name = line[0]
            if len(mun_name.split(' ')) > 1:
                mun_name = ' '.join(mun_name.split(
                    ' ')[:-1]) + ' ' + mun_name.split(' ')[-1].lower()
            v.write(f"""INSERT INTO EV_Datum (mun_name, county, year, num_ev, num_vehicles)
            VALUES ('{mun_name.strip()}', '{line[1].strip()}', {line[2]}, {numeric(line[4])}, {numeric(line[3])});\n""")
