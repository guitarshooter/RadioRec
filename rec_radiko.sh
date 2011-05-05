#!/bin/sh
BASE64=/usr/bin/base64
FFMPEG=/usr/local/bin/ffmpeg
#GROWLNOTIFY=/usr/local/bin/growlnotify
PERL=/usr/bin/perl
RTMPDUMP=/usr/bin/rtmpdump
SWFEXTRACT=/usr/local/bin/swfextract
WGET=/usr/bin/wget

playerurl=http://radiko.jp/player/swf/player_2.0.1.00.swf
playerfile=./player.swf
keyfile=./authkey.png

if [ $# -eq 2 ]; then
  CHANNEL=$1
  RECTIMEMIN=$2
else
  echo "usage : $0 CHANNEL RECTIMEMIN OUTFILEPREFIX"
  exit 1
fi

OUTFILEBASEPATH=/root
cd $OUTFILEBASEPATH

#
# get player
#
if [ ! -f $playerfile ]; then
  $WGET -q -O $playerfile $playerurl

  if [ $? -ne 0 ]; then
    echo "failed get player"
    exit 1
  fi
fi

#
# get keydata (need swftool)
#
if [ ! -f $keyfile ]; then
  $SWFEXTRACT -b 5 $playerfile -o $keyfile

  if [ ! -f $keyfile ]; then
    echo "failed get keydata"
    exit 1
  fi
fi

if [ -f auth1_fms ]; then
  rm -f auth1_fms
fi

#
# access auth1_fms
#
$WGET -q \
     --header="pragma: no-cache" \
     --header="X-Radiko-App: pc_1" \
     --header="X-Radiko-App-Version: 2.0.1" \
     --header="X-Radiko-User: test-stream" \
     --header="X-Radiko-Device: pc" \
     --post-data='\r\n' \
     --no-check-certificate \
     --save-headers \
     https://radiko.jp/v2/api/auth1_fms

if [ $? -ne 0 ]; then
  echo "failed auth1 process"
  exit 1
fi

#
# get partial key
#
authtoken=`$PERL -ne 'print $1 if(/x-radiko-authtoken: ([\w-]+)/i)' auth1_fms`
offset=`$PERL -ne 'print $1 if(/x-radiko-keyoffset: (\d+)/i)' auth1_fms`
length=`$PERL -ne 'print $1 if(/x-radiko-keylength: (\d+)/i)' auth1_fms`

partialkey=`dd if=$keyfile bs=1 skip=${offset} count=${length} 2> /dev/null | $BASE64`

echo "authtoken: ${authtoken} \noffset: ${offset} length: ${length} \npartialkey: $partialkey"

rm -f auth1_fms

if [ -f auth2_fms ]; then
  rm -f auth2_fms
fi

#
# access auth2_fms
#
$WGET -q \
     --header="pragma: no-cache" \
     --header="X-Radiko-App: pc_1" \
     --header="X-Radiko-App-Version: 2.0.1" \
     --header="X-Radiko-User: test-stream" \
     --header="X-Radiko-Device: pc" \
     --header="X-Radiko-Authtoken: ${authtoken}" \
     --header="X-Radiko-Partialkey: ${partialkey}" \
     --post-data='\r\n' \
     --no-check-certificate \
     https://radiko.jp/v2/api/auth2_fms

if [ $? -ne 0 -o ! -f auth2_fms ]; then
  echo "failed auth2 process"
  exit 1
fi

echo "authentication success"

areaid=`$PERL -ne 'print $1 if(/^([^,]+),/i)' auth2_fms`
echo "areaid: $areaid"

rm -f auth2_fms

# foreplay
MARGINTIMEMIN=0
RECTIME=`expr $RECTIMEMIN \* 60 + $MARGINTIMEMIN \* 2 \* 60`

#$GROWLNOTIFY -t $OUTFILEPREFIX -m 'start'

#
# rtmpdump
#
$RTMPDUMP -v \
         -r "rtmpe://radiko.smartstream.ne.jp" \
         --playpath "simul-stream" \
         --app "${CHANNEL}/_defInst_" \
         -W $playerurl \
         -C S:"" -C S:"" -C S:"" -C S:$authtoken \
         --live \
         --stop $RECTIME | \
# afterplay
#$FFMPEG -i - -vn -acodec libfaac $OUTFILEBASEPATH/`date +%y%m%d`-$OUTFILEPREFIX.m4a
#$FFMPEG -i - -vn -acodec copy $OUTFILEBASEPATH/`date +%y%m%d`-$OUTFILEPREFIX.aac
$FFMPEG -i - -vn -acodec libmp3lame -ab 128 -ar 44100 $OUTFILEBASEPATH/`date +%Y%m%d`.mp3

#$GROWLNOTIFY -t $OUTFILEPREFIX -m 'finish'

