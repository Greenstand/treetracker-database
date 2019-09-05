docker run --rm --name greenstand-postgres -d \
    -e POSTGRES_DBNAME=treetracker \
    -p 5432:5432 \
    -v $HOME/docker/volumes/treetracker:/var/lib/postgresql/data \
    kartoza/postgis:9.6-2.4
