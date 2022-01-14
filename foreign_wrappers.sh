#!/bin/bash

# Uruchomienie 'głównej' bazy danych
/usr/pgsql-13/bin/pg_ctl -D /var/lib/pgsql/13/data start

# Utworzenie rozszerzenia pozwalającego na skorzystanie z tabel innych instancji postgresa
psql -p 5432 -c "create extension postgres_fdw;"

# Zdefiniowanie połączenia poprzez FDW

psql -p 5432 -c "create server pgsql_5433 foreign data wrapper postgres_fdw options (host 'localhost',port '5433');"

psql -p 5432 -c "create user mapping for public server pgsql_5433 options (user 'postgres', password 'postgres');"

psql -p 5432 -c "create server pgsql_5434 foreign data wrapper postgres_fdw options (host 'localhost',port '5434');"

psql -p 5432 -c "create user mapping for public server pgsql_5434 options (user 'postgres', password 'postgres');"

psql -p 5432 -c "create server pgsql_5435 foreign data wrapper postgres_fdw options (host 'localhost',port '5435');"

psql -p 5432 -c "create user mapping for public server pgsql_5435 options (user 'postgres', password 'postgres');"

# Tworzenie tabel obcych

psql -p 5432 -c "create foreign table measurements_atlantic (m_id serial,m_timestamp timestamp,m_attribute varchar(40),m_value numeric(10,2)) server pgsql_5433 options (table_name 'measurements');"

psql -p 5432 -c "create foreign table measurements_pacific (m_id serial,m_timestamp timestamp,m_attribute varchar(40),m_value numeric(10,2)) server pgsql_5434 options (table_name 'measurements');"

psql -p 5432 -c "create foreign table measurements_indian (m_id serial,m_timestamp timestamp,m_attribute varchar(40),m_value numeric(10,2)) server pgsql_5435 options (table_name 'measurements');"

# Wyświetlenie danych

echo "Atlantic"
psql -p 5432 -c "select * from measurements_atlantic;"

echo "Pacific"
psql -p 5432 -c "select * from measurements_pacific;"

echo "Indian"
psql -p 5432 -c "select * from measurements_indian;"
