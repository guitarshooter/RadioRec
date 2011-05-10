use MP3::Tag;
($title,$album,$artist,@file) = @ARGV;

foreach $mp3file (@file){
$mp3 = MP3::Tag->new($mp3file);
#($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
$mp3->get_tags();
$mp3->new_tag("ID3v2") if (!exists $mp3->{ID3v2});

    $mp3->{ID3v2}->add_frame("TIT2", 1, "$title");
    $mp3->{ID3v2}->add_frame("TALB", 1, "$album");
    $mp3->{ID3v2}->artist("$artist");
    $mp3->{ID3v2}->write_tag();
    $mp3->{ID3v2}->close();
    }
