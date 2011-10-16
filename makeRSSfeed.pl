#!/usr/bin/perl
# Usage: makeRSSfeed.sh [Time(s)]
use MP3::Tag;
use File::Basename;
use Data::Dumper;

$RSSFEED="podcast.xml";
$DOCROOT="http://192.168.11.5/radio";
$ROOTDIR="/var/www/radio";
#$LOGFILE=$ROOTDIR/makerss.log;

@ARGV = reverse sort @ARGV;

open(FH,">$ROOTDIR/$RSSFEED");

print FH <<EOF; 
<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
<channel>
<title>My Radio Podcast</title>
<description>My Radio Podcast</description> 
<language>ja</language>
EOF

foreach $mp3file (@ARGV){
#print $mp3file;
$mp3 = MP3::Tag->new($mp3file);
#($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
@mp3tag = $mp3->autoinfo();
s/&/&amp;/g foreach @mp3tag;
s/</&lt;/g foreach @mp3tag;
s/>/&gt;/g foreach @mp3tag;
s/'/&apos;/g foreach @mp3tag;
s/"/&quot;/g foreach @mp3tag;
s/( mixi.+ )//g foreach @mp3tag;

($title, $track, $artist, $album, $comment, $year, $genre) = @mp3tag;

#unless($title){
#$title=$mp3file;
#}

$basename = basename($mp3file);
$YYYY = substr($basename,0,4);
$MM = substr($basename,4,2);
$DD = substr($basename,6,2);
$date = $YYYY."/".$MM."/".$DD;

#print $title;
$rss="<item>
<title>$title</title>
<description>$comment</description>
<itunes:author>$artist</itunes:author>
<itunes:subtitle>$title</itunes:subtitle>
<itunes:summary>$comment</itunes:summary>
<enclosure url=\"$DOCROOT/$basename\" type=\"audio/mpeg\" />
<guid>$DOCROOT/$basename</guid>
<pubDate>$date</pubDate>
</item>

";

print FH $rss;

}
print FH "</channel>","\n";
print FH "</rss>";

exit;
