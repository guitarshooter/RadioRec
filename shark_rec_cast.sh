#!/bin/bash
# Usage: makeRSSfeed.sh [Time(s)]

ROOTDIR=/var/www/radio
#ROOTDIR=/var/www/dav
FILENAME=`date +%Y%m%d%H%M`
TITLE="`date +%Y/%m/%d`_$3"
STARTTIME=`date +%H:%M`
MAKERSS=/root/bin/makeRSSfeed.sh
DEVNO=`grep '\[radioSHARK' /proc/asound/cards |awk '{print $1;}'`


if [ $# -ne 5 ]; then
echo "usage:$0 Time(s) FM Title Artist Album\n" 
echo "FM:TFM BAY-FM NHK-FM J-WAVE NACK5 FMyokohama INTERFM FMurayasu NHK-TV NHKkyouiku"
exit 1;
fi

case $2 in
 "TFM" ) HZ=78.9;;
 "BAY-FM" ) HZ=76.8;;
 "NHK-FM" ) HZ=80.9;;
 "J-WAVE" ) HZ=80.3;;
 "NACK5" ) HZ=78.3;;
 "FMyokohama" ) HZ=81.6;;
 "INTERFM" ) HZ=82.2;;
# "FMurayasu" ) HZ=85.0;;
  "FM-FUJI" ) HZ=77.4;;
 "NHK-TV" ) HZ=95.7;;
 "housoudaigaku" ) HZ=82.8;;
 "NHKkyouiku" ) HZ=107.7;;
 *) echo "FM Not Found!";exit 1;;
esac

echo `date`": Record Start..." >$ROOTDIR/log.txt
cd $ROOTDIR
/usr/local/bin/shark2 -red 1
/usr/local/bin/shark2 -fm $HZ
#/usr/bin/arecord -f cd -d $2 -q -M | /usr/local/bin/lame -b 128 -m s - $FILENAME.mp3
#/usr/bin/ecasound -i /dev/dsp1 -o:stdout -t:$1 -z:nodb -z:intbuf|/usr/local/bin/lame -r -x -m s -b 128 - $FILENAME.mp3 >>$ROOTDIR/log.txt 2>&1
#/usr/bin/ecasound -i /dev/dsp1 -o:stdout -t:$1 -z:nointbuf|/usr/local/bin/lame -r -x -m s -b 128 - $FILENAME.mp3 >>$ROOTDIR/log.txt 2>&1
/usr/bin/ecasound -i /dev/dsp$DEVNO -o:stdout -t:$1 |/usr/local/bin/lame -r -x -m s -b 128 - $FILENAME.mp3 >>$ROOTDIR/log.txt 2>&1
ENDTIME=`date +%H:%M`
sleep 10
#/root/bin/set_mp3tag.pl $FILENAME.mp3 $2 $3 $4 $5 $STARTTIME $ENDTIME
/root/bin/set_mp3tag.pl $FILENAME.mp3 $2 "$TITLE" "$4" "$5" $STARTTIME $ENDTIME >>$ROOTDIR/log.txt 2>&1
/root/bin/makeRSSfeed.pl $ROOTDIR/*.mp3 >>$ROOTDIR/log.txt 2>&1
find . -name \*.mp3 -ctime +28 |xargs rm -v >>$ROOTDIR/log.txt
/usr/local/bin/shark2 -red 0
echo `date`": Record End..." >>$ROOTDIR/log.txt
