DB_TO_KEEP="reallystick"
psql -U reallystick -d postgres -Atc "SELECT datname FROM pg_database WHERE datname NOT IN ('postgres', '$DB_TO_KEEP') AND datistemplate = false;" | while read db; do
    echo "Dropping database: $db"
    psql -U reallystick -d postgres -c "DROP DATABASE \"$db\";"

done