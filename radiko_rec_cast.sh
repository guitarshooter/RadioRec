#!/bin/bash
# Usage: makeRSSfeed.sh [Time(s)]

ROOTDIR=/var/www/html/radio
FILENAME=`date +%Y%m%d%H%M`
TITLE="`date +%Y/%m/%d`_$3"
STARTTIME=`date +%H:%M`
BINDIR="/home/shooter/bin"

if [ $# -ne 5 ]; then
echo "usage:$0 Time(m) CHANNEL Title Artist Album" 
echo "CHANNEL:TFM BAY-FM J-WAVE NACK5 FMyokohama TBS QRR LFR NSB JORF"
exit 1;
fi

echo `date`": Record Start..." >$ROOTDIR/radikolog.txt
cd $ROOTDIR
$BINDIR/rec_radiko.sh $2 $1 $FILENAME.mp3
ENDTIME=`date +%H:%M`
sleep 10
$BINDIR/set_mp3tag.pl $FILENAME.mp3 $2 "$TITLE" "$4" "$5" $STARTTIME $ENDTIME >>$ROOTDIR/log.txt 2>&1
$BINDIR/makeRSSfeed.pl $ROOTDIR/*.mp3 >>$ROOTDIR/log.txt 2>&1
echo `date`": Record End..." >>$ROOTDIR/log.txt
