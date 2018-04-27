echo 'drop database treetracker_migrate' | mysql -u root 
echo 'create database treetracker_migrate' | mysql -u root
ssh jezra@treetracker.org source mysql.dump.treetracker.sh
scp jezra@treetracker.org:treetracker.mysql .
mysql -u root treetracker_migrate < treetracker.mysql 
py-mysql2pgsql
