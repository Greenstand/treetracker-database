rm treetracker.mysql
rm treetracker.pgsql
echo 'drop database treetracker_migrate' | mysql -u root 
echo 'create database treetracker_migrate' | mysql -u root
ssh jezra@treetracker.org source mysql.dump.treetracker.sh
scp jezra@treetracker.org:treetracker.mysql .
mysql -u root treetracker_migrate < treetracker.mysql 
echo "ALTER TABLE trees ADD image_url VARCHAR(200) DEFAULT NULL; SET SQL_SAFE_UPDATES = 0; UPDATE trees t LEFT JOIN ( SELECT tree_id, MIN(photo_id) photo_id FROM photo_trees GROUP BY tree_id) p ON p.tree_id = t.id SET image_url =  CONCAT('https://treetracker-dev.nyc3.digitaloceanspaces.com/',p.photo_id,'.jpg' );" | mysql -u root treetracker_migrate 
py-mysql2pgsql
