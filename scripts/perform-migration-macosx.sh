source convert.mysql.to.pgsql.sh
source import.pgsql.to.migrate.macosx.sh
cd ../
db-migrate --env localhost up
