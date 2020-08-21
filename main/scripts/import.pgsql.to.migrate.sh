echo 'DROP DATABASE treetracker_migrate' | sudo -u postgres psql
echo 'CREATE DATABASE treetracker_migrate' | sudo -u postgres psql
echo 'CREATE EXTENSION postgis' | sudo -u postgres psql treetracker_migrate
sudo -u postgres psql treetracker_migrate < treetracker.pgsql
echo 'GRANT ALL PRIVILEGES ON DATABASE treetracker_migrate TO treetracker' | sudo -u postgres psql
echo 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO treetracker' | sudo -u postgres psql treetracker_migrate
echo 'ALTER USER postgres SET search_path TO "$user", public, postgis;' | sudo -u postgres psql
echo 'ALTER USER treetracker SET search_path TO "$user", public, postgis;' | sudo -u postgres psql


