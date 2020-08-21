echo 'DROP DATABASE treetracker_migrate' | psql template1
echo 'CREATE DATABASE treetracker_migrate' | psql template1
echo 'CREATE EXTENSION postgis' | psql treetracker_migrate
psql treetracker_migrate < treetracker.pgsql
echo 'GRANT ALL PRIVILEGES ON DATABASE treetracker_migrate TO zaven' | psql treetracker_migrate
echo 'ALTER USER zaven SET search_path TO "$user", public, postgis;' | psql treetracker_migrate


