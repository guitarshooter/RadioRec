#!/bin/bash
# Usage: makeRSSfeed.sh [Time(s)]

ROOTDIR=/var/www/radio
FILENAME=`date +%Y%m%d%H%M`
TITLE="`date +%Y/%m/%d`_$3"
STARTTIME=`date +%H:%M`
MAKERSS=/root/bin/makeRSSfeed.sh

if [ $# -ne 5 ]; then
echo "usage:$0 Time(s) FM Title Artist Album" 
exit 1;
fi

echo `date`": Record Start..." >$ROOTDIR/log.txt
cd $ROOTDIR
#/usr/bin/arecord -f cd -d $2 -q -M | /usr/local/bin/lame -b 128 -m s - $FILENAME.mp3
#/usr/bin/ecasound -i /dev/dsp1 -o:stdout -t:$1 -z:nodb -z:intbuf|/usr/local/bin/lame -r -x -m s -b 128 - $FILENAME.mp3 >>$ROOTDIR/log.txt 2>&1
#/usr/bin/ecasound -i /dev/dsp1 -o:stdout -t:$1 -z:nointbuf|/usr/local/bin/lame -r -x -m s -b 128 - $FILENAME.mp3 >>$ROOTDIR/log.txt 2>&1
/usr/bin/ecasound -i /dev/dsp1 -o:stdout -t:$1 |/usr/local/bin/lame -r -x -m s -b 128 - $FILENAME.mp3 >>$ROOTDIR/log.txt 2>&1
ENDTIME=`date +%H:%M`
sleep 60
#/root/bin/set_mp3tag.pl $FILENAME.mp3 $2 $3 $4 $5 $STARTTIME $ENDTIME
/root/bin/set_mp3tag.pl $FILENAME.mp3 $2 "$TITLE" "$4" "$5" $STARTTIME $ENDTIME
/root/bin/makeRSSfeed.pl $ROOTDIR/*.mp3
find . -name \*.mp3 -ctime +28 |xargs rm -v >>$ROOTDIR/log.txt
echo `date`": Record End..." >>$ROOTDIR/log.txt
