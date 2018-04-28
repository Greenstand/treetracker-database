echo 'DROP DATABASE treetracker_migrate' | sudo -u postgres psql
echo 'CREATE DATABASE treetracker_migrate' | sudo -u postgres psql
sudo -u postgres psql treetracker_migrate < treetracker.pgsql
echo 'GRANT ALL PRIVILEGES ON DATABASE treetracker_migrate TO treetracker' | sudo -u postgres psql

