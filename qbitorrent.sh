#!/bin/bash

wickedList=('trident+AND+mediaguard' 'hadopi' 'trident+AND+media+AND+guard')
rtorrentFile="iplist.dat"

tmpWickedFile='/tmp/tmpWickedFile.txt'
tmpWorkFile='/tmp/tmpWorkFile.txt'

rm -f "${rtorrentFile}" 2> /dev/null

for m in "${wickedList[@]}"; do
    curl -s -o "${tmpWickedFile}" "https://apps.db.ripe.net/db-web-ui/api/rest/fulltextsearch/select?facet=true&format=xml&hl=true&q=(${m})&start=0&wt=json" -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:62.0) Gecko/20100101 Firefox/62.0' --compressed
    cat "${tmpWickedFile}" | sed s/\<\\/str\>/\\n/g | grep 'str name="inetnum"' | sed 's/.*>//' >> "${tmpWorkFile}"
    rm -f "${tmpWickedFile}"
done

compteur=0
while read -r line; do
    ip1=`echo "$line" | cut -d'-' -f1`
    ip2=`echo "$line" | cut -d'-' -f2`
    printf "%03d.%03d.%03d.%03d" $(echo "$ip1" | cut -d'.' --output-delimiter=' ' -f1-4) >> "${rtorrentFile}"
    printf " - " >> "${rtorrentFile}"
    printf "%03d.%03d.%03d.%03d" $(echo "$ip2" | cut -d'.' --output-delimiter=' ' -f1-4) >> "${rtorrentFile}"
    printf " , 000 , hadopi%d\n" $compteur >> "${rtorrentFile}"
    compteur=`expr "$compteur" + 1`
done < "${tmpWorkFile}"
