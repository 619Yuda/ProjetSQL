echo -e "-- File created by CsvToSql.sh $(date)\n-- Conversion from Oracle to psql\n" > Data.sql

for i in $*; do
    
    bn=$(basename $i .csv)

    var=$(head -n 1 "$i" | tr '\t' ',')
   
    echo -e "\nINSERT ALL" >> Data.sql

    tail "$i" -n +2\
    | tr '\t' ','\
    | sed 's/\([^,]*\)/#\1#/g'\
    | sed 's/\(^.*$\)/  INTO '$bn' ('$var') VALUES (\1)/g'\
    | sed '$ s/)$/)\nSELECT \* FROM dual;/g' \
    | sed 's/#\([0-9]\{1,4\}\)#/\1/g' \
    | sed 's/#NULL#/NULL/g' \
    | sed 's/#\(Sysdate-[0-9]\{1,4\}\)#/\1/g' \
    | tr '#' ''\''' >> Data.sql

done;
