#!/usr/bin/perl
# @ARGV mp3file,time,fm

use MP3::Tag;
use LWP::UserAgent;
use WWW::Mechanize;
use Jcode;
use HTML::TableExtract;
use HTML::TreeBuilder;
use JSON;
use Data::Dumper;

if(@ARGV ne 7){
print "usage: $0 mp3filename FM Title Artist Album Starttime Endtime","\n";
exit;
}

($mp3file,$FM,$title,$artist,$album,$starttime,$endtime) = @ARGV;
($mday,$mon,$year) = (localtime(time))[3..5];
$year += 1900;
$mon += 1;
$mon = "0".$mon;
$mon = substr($mon,-2);
$mday = "0".$mday;
$mday = "0".$mday;
$mday = substr($mday,-2);
$yyyymmdd=$year.$mon.$mday;
$starttime2 = $starttime;
$endtime2 = $endtime;
$starttime2 =~ s/://;
$endtime2 =~ s/://;
if($FM eq "BAY-FM" && $starttime2 <= 400){
  $starttime2 = 2400 + $starttime2;
  $endtime2 =  2400 + $endtime2;
}
$stime = substr($starttime,0,2);

eval{
@list = &get_list($FM);
};


if(@list){
foreach $row2 (@list) {
#print join(",",@$row2);
#shift @$row2;
$row2time = $$row2[0];
$row2time =~ s/://;
$row2time = substr($row2time,0,4);
#print $row2time,"\n";
if($row2time >= $starttime2 && $row2time <= $endtime2){ 
       $time = shift(@$row2);
       $str .= $time." ";
       $str .= join('/', @$row2);
       $str .= "\n";
       }
}
}else{
$str = $FM;
}

print $str,"\n";
#exit;

#print $mp3file,"\n";
&mp3_writetag($mp3file,$title,$artist,$album,$str);


sub mp3_writetag($mp3file,$title,$artist,$album,$comment){
($mp3file,$title,$artist,$album,$comment) = @_;

MP3::Tag->config("write_v24" => 1);
$mp3 = MP3::Tag->new($mp3file);
#($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
$mp3->get_tags();
$mp3->{ID3v2}->remove_tag if (exists $mp3->{ID3v2});
$mp3->new_tag("ID3v2");

$mp3->{ID3v2}->add_frame("TIT2", 1, "$title");
#$mp3->{ID3v2}->add_frame("TRCK", 1, "Track");
$mp3->{ID3v2}->artist("$artist");

$mp3->{ID3v2}->add_frame("TALB", 1, "$album");
$mp3->{ID3v2}->comment("$comment");
$mp3->{ID3v2}->write_tag();
$mp3->close();
}


sub get_list($fm){
$fm = shift @_;

unless($fm eq "TFM" || $fm eq "BAY-FM" || $fm eq "J-WAVE" || $fm eq "NACK5" || $fm eq "FMyokohama"){
return;
}

if($fm eq "BAY-FM"){
$url = "http://song.bayfm.jp/song/";
#$url="http://song.bayfm.jp/song/result.cgi?month=20110910&stime=&submit.x=72&submit.y=8&submit=Search";

$headers = ['','',''];
$depth = 0;
$count = 0;
$reverseFlg=1;
}
elsif($fm eq "FMyokohama"){
$url = "http://search.fmyokohama.co.jp/songsearch/query/querysong2.php?STime=$yyyymmdd".$starttime2."&ETime=".$yyyymmdd.$endtime2."&MaxRow=300";
$headers = [qw(Time Title Artist)];
$depth = 2;
$count = 3;
$reverseFlg=1;
}
elsif($fm eq "J-WAVE"){
$url = "http://www.j-wave.co.jp/songlist/pc.html";
$headers = [qw(Time Title Artist)];
$depth = 1;
$count = 4;
$reverseFlg=1;
}
elsif($fm eq "NACK5"){
$url = "http://www.fm795.com/onairsearch/onairlist795_5.php?day=$mday&year=$year&month=$mon&stime=$stime";
$headers = [qw(時間 曲（タイトル名） アーティスト名)];
$depth = 0;
$count = 0;
$reverseFlg=0;
}
elsif($fm eq "TFM" ){
$url = "http://www.tfm.co.jp/nowonair/search.php";
}

#print $fm,"\n";
#print $url,"\n";

my $ua = WWW::Mechanize->new(
       agent =>        'Mozilla/4.0 (compatible; MSIE 6.0)',
       timeout =>      60,
       max_size =>     128 * 1024,
       );
#       print $url;
my $response = $ua->get( $url );
#if($fm eq "BAY-FM"){
##  $ua->follow_link("./pc/TodayResult.html");
#  $ua->follow_link(name => "viewer");
#}
#$content = $response->content;
$content = $ua->content;
print $content;

if ($response->is_success) {
  $code=Jcode::getcode(\$content);
  $content = Jcode::convert(\$content,utf8,$code);

# TFM
if($fm eq "TFM"){
my $tree = HTML::TreeBuilder->new();
$tree->parse($content);

@artist = $tree->look_down("class","entry_artist");
@title = $tree->look_down("class", "entry_title");
@time = $tree->look_down("class", "entry_time");

foreach $attr (@artist){
    @tim_tit_art = ();
    $art = $attr->as_text;
    $attr_title = shift(@title);
    $tit = $attr_title->as_text;
    $tit =~ s/( mixi.+ )//g;
    $attr_time = shift(@time);
    $tim = $attr_time->as_text;
    $tim_tit_art = [$tim,$tit,$art];
    unshift(@list,$tim_tit_art);
    #    print $tim." ".$tit."/".$art."\n";
  }
}elsif($fm eq "FMyokohama"){
print "-------------------\n";
  $json = new JSON;
  $json_list = $json->utf8(1)->decode($content);
#$json_list = decode_json $content;
  foreach $attr (@$json_list){
    $tim = substr($$attr{start_time},0,5);
    $tit = $$attr{title1};
    $art = $$attr{artist1};
    $tim_tit_art = [$tim,$tit,$art];
    push(@list,$tim_tit_art);
#    print $tim." ".$tit."/".$art."\n";
#    print $$attr{title1};
#     print Data::Dumper->Dump( [ $attr ],[ '*$attr' ] );
  }
}
#TFM igai
else{
  my $te = new HTML::TableExtract(
                         headers => $headers,
			 depth => $depth,
			 count => $count,
			        );
  $te->parse($content);

foreach $row ($te->rows) {
  if($reverseFlg == "1"){
	unshift(@list,$row);
  }elsif(reverseFlg == "0"){
    push(@list,$row);
  }
}
}
}else{
return;
}

return @list;
}

