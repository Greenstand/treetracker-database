echo 'DROP DATABASE treetracker_migrate' | sudo -u postgres psql
echo 'CREATE DATABASE treetracker_migrate' | sudo -u postgres psql
echo 'GRANT ALL PRIVILEGES ON DATABASE treetracker_migrate TO treetracker' | sudo -u postgres psql
echo 'CREATE EXTENSION postgis' | sudo -u postgres psql treetracker_migrate
psql -U treetracker -h localhost < treetracker.pgsql

