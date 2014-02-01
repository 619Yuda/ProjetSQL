echo -e "-- File created by CsvToSql.sh $(date)\n-- Version for Oracle\n" > Fill_table_or.sql
for i in $*; do

    bn=$(basename $i .csv)

    var=$(head -n 1 "$i" | tr '\t' ',')

    echo -e "\n" >> Fill_table_or.sql
    tail "$i" -n +2\
    | tr '\t' ',' \
    | sed 's/\([^,]*\)/#\1#/g' \
    | sed 's/\(^.*$\)/INSERT INTO '$bn' ('$var') VALUES (\1);/g' \
    | sed 's/#\([0-9]\{1,4\}\)#/\1/g' \
    | sed 's/#NULL#/NULL/g' \
    | sed 's/#\(Sysdate-[0-9]\{1,4\}\)#/\1/g' \
    | sed 's/#\(.*NEXTVAL\)#/\1/g' \
    | tr '#' ''\''' >> Fill_table_or.sql

done;
