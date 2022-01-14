#!/bin/bash

# Uruchomienie bazy danych

/usr/pgsql-13/bin/pg_ctl -D /var/lib/pgsql/13/data start

# Utworzenie uzytkownika obslugujacego replikacje

psql -c "create role replication password 'replication' replication login"

# Dodanie parametrów usprawiniających replikacje

echo "listen_addresses = '*'" >> /var/lib/pgsql/13/data/postgresql.conf
echo "max_wal_senders = 3" >> /var/lib/pgsql/13/data/postgresql.conf

# Zezwolenie serwerowi standby na połączenie do master node'a

echo "host    replication    replication    0.0.0.0/0    md5" >> /var/lib/pgsql/13/data/pg_hba.conf

# Restart master node'a

/usr/pgsql-13/bin/pg_ctl -D /var/lib/pgsql/13/data restart

# Ustawienie replication slotu

psql -c "select pg_create_physical_replication_slot('slot1');"

# Utworzenie tabeli

psql -c "create table measurements(m_id serial,m_timestamp timestamp,m_attribute varchar(40),m_value numeric(10,2));"

# Wstawienie danych do tabeli

psql -c "insert into measurements (m_timestamp, m_attribute, m_value) values (current_timestamp, 'temp0dbar', 12.1), (current_timestamp, 'temp1000dbar', 3.82),(current_timestamp, 'temp2000dbar', 2.04), (current_timestamp + interval '1 minute', 'temp0dbar', 12.12), (current_timestamp + interval '1 minute', 'temp1000dbar', 3.63), (current_timestamp + interval '1 minute', 'temp2000dbar', 1.98);"
