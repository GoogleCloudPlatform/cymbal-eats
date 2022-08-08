echo "Connecting to $DB_HOST"
createdb -h $DB_HOST -p 5432 $PGDB
echo "Created $PGDB database"

psql -h $DB_HOST -l
