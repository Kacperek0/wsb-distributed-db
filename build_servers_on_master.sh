#!/bin/bash

# Tworzenie i uruchomienie 3 node'ów PostgreSQL na serwerze w centrali

# Tworzenie katalogów i tworzenie DataDirectory dla kazdego node'a
mkdir -p nodes/atlantic nodes/pacific nodes/indian

/usr/pgsql-13/bin/initdb -D nodes/atlantic
/usr/pgsql-13/bin/initdb -D nodes/pacific
/usr/pgsql-13/bin/initdb -D nodes/indian

# Czyczenie DataDirectory bez kopii zapasowej bo nie boimy się niczego :)

rm -rf nodes/atlantic/
pg_basebackup -h 10.0.0.2 -D nodes/atlantic -P -U replication --slot=slot1

rm -rf nodes/pacific/
pg_basebackup -h 10.0.0.3 -D nodes/atlantic -P -U replication --slot=slot1

rm -rf nodes/indian/
pg_basebackup -h 10.0.0.4 -D nodes/atlantic -P -U replication --slot=slot1

# Zmiana portów w plikach konfiguracyjnych Postgresa dla kadego z node'ów

echo "port = 5433" >> nodes/atlantic/postgresql.conf
echo "port = 5434" >> nodes/pacific/postgresql.conf
echo "port = 5435" >> nodes/indian/postgresql.conf

# Konfiguracja standby node'ów

echo "hot_standby = on" >> nodes/atlantic/postgresql.conf
echo "primary_conninfo = 'host=10.0.0.2 port=5432 user=replication password=replication'" >> nodes/atlantic/postgresql.conf
echo "primary_slot_name = 'slot1'" >> nodes/atlantic/postgresql.conf
touch nodes/atlantic/standby.signal

echo "hot_standby = on" >> nodes/pacific/postgresql.conf
echo "primary_conninfo = 'host=10.0.0.3 port=5432 user=replication password=replication'" >> nodes/pacific/postgresql.conf
echo "primary_slot_name = 'slot1'" >> nodes/pacific/postgresql.conf
touch nodes/pacific/standby.signal

echo "hot_standby = on" >> nodes/indian/postgresql.conf
echo "primary_conninfo = 'host=10.0.0.4 port=5432 user=replication password=replication'" >> nodes/indian/postgresql.conf
echo "primary_slot_name = 'slot1'" >> nodes/indian/postgresql.conf
touch nodes/indian/standby.signal

# Uruchomienie serwerów PostgreSQL

/usr/pgsql-13/bin/pg_ctl -D nodes/atlantic start
/usr/pgsql-13/bin/pg_ctl -D nodes/pacific start
/usr/pgsql-13/bin/pg_ctl -D nodes/indian start

# Sprawdzenie replikacji

echo "Atlantic"
psql -p 5433 -c "select m_attribute, round(avg(m_value),4) from measurements group by m_attribute;"
psql -p 5433 -c "select m_timestamp, count(*) from measurements group by m_timestamp order by m_timestamp desc limit 1;"

echo "Pacific"
psql -p 5434 -c "select m_attribute, round(avg(m_value),4) from measurements group by m_attribute;"
psql -p 5434 -c "select m_timestamp, count(*) from measurements group by m_timestamp order by m_timestamp desc limit 1;"

echo "Indian"
psql -p 5435 -c "select m_attribute, round(avg(m_value),4) from measurements group by m_attribute;"
psql -p 5435 -c "select m_timestamp, count(*) from measurements group by m_timestamp order by m_timestamp desc limit 1;"
