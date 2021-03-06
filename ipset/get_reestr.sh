#!/bin/sh
# get rublacklist and resolve it

SCRIPT=$(readlink -f $0)
EXEDIR=$(dirname $SCRIPT)

. "$EXEDIR/def.sh"

ZREESTR=$TMPDIR/zapret.txt
ZDIG=$TMPDIR/zapret-dig.txt
ZIPLISTTMP=$TMPDIR/zapret-ip.txt
#ZURL=https://reestr.rublacklist.net/api/current
ZURL=https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv

getuser

curl -k --fail --max-time 300 --max-filesize 62914560 "$ZURL" >$ZREESTR ||
{
 echo reestr list download failed   
 exit 2
}
dlsize=$(wc -c "$ZREESTR" | cut -f 1 -d ' ')
if test $dlsize -lt 204800; then
 echo list file is too small. can be bad.
 exit 2
fi
echo preparing dig list ..
#sed -i 's/\\n/\r\n/g' $ZREESTR
#sed -nre 's/^[^;]*;([^;|\\]{4,250})\;.*$/\1/p' $ZREESTR | sort | uniq >$ZDIG
cut -f2 -d';' $ZREESTR  | grep -avE '^$|\*|:' >$ZDIG
rm -f $ZREESTR
echo digging started ...
digger $ZDIG | cut_local >$ZIPLISTTMP || {
 rm -f $ZDIG
 exit 1
}
rm -f $ZDIG $ZIPLIST
sort -u $ZIPLISTTMP >$ZIPLIST
rm -f $ZIPLISTTMP
"$EXEDIR/create_ipset.sh"

