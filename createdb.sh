dropdb sustainability
createdb sustainability

psql sustainability -f sql/DDL.sql
psql sustainability -f sql/insert_mun.sql
psql sustainability -f sql/insert_ev.sql
psql sustainability -f sql/insert_ghg.sql
psql sustainability -f sql/insert_vehicles.sql