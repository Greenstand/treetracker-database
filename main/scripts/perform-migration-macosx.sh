source convert.mysql.to.pgsql.sh
source import.pgsql.to.migrate.macosx.sh
cd ../
db-migrate --env localhost up
pg_dump --no-owner treetracker_migrate > treetracker_migrate.pgsql
sed -i '' '/    AS integer/d' ./treetracker_migrate.pgsql
