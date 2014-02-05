echo -e "-- File created by CsvToSql.sh $(date)\n-- Conversion from Oracle to psql\n" > 3_Fill_table_pg.sql

for i in $*; do
    bn=$(basename $i .csv)
    echo -e "Processing $bn"

    head -n 1 "$i"\
    | tr '\t' ','\
    | sed 's/\(^.*$\)/\nINSERT INTO '$bn' (\1) VALUES/g' >> 3_Fill_table_pg.sql

    tail "$i" -n +2\
    | tr '\t' ','\
    | sed 's/\([^,]*\)/#\1#/g'\
    | sed 's/\(^.*$\)/(\1),/g'\
    | sed '$ s/,$/;/g' \
    | sed 's/#\([0-9]\{1,4\}\)#/\1/g' \
    | sed 's/#NULL#/NULL/g' \
    | sed 's/#Sysdate-\([0-9]\{1,4\}\)#/CURRENT_TIMESTAMP - INTERVAL #\1 days#/g' \
    | tr '#' ''\''' >> 3_Fill_table_pg.sql
done;
