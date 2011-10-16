#!/usr/bin/perl

use strict;
use warnings;
use MP3::Info;
use Data::Dumper;

main();

sub main {
    my $file = $ARGV[0];
    my $tag = get_mp3tag($file);
    my $info = get_mp3info($file);
   print Dumper($tag, $info);
}
