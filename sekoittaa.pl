#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;

if ($#ARGV < 0) {
    print "Usage: sekoittaa.pl <input wav|flac|mp3> [output]\n";
    exit 1;
}

my $input_file = $ARGV[0];
my ($name, $path, $ext) = fileparse($input_file);
my $output_file = $#ARGV ? $ARGV[1] : "$name-sekoitted.$ext";

my $contents;
open(my $in, '<', $input_file) 
    or die "Could not open file $input_file\n";
{
    local $/;
    $contents = <$in>;
}

# identify file type
my $magic = substr($contents, 0, 12);
if ($magic =~ m/RIFF[\x00-\xff]{4}WAVE/) {
    print "wav";
} elsif ($magic =~ m/\xff[\xf2\xf3\xfb]|ID3/) {
    print "mp3";
} elsif ($magic =~ m/fLaC/) {
    print "flac";
} else {
    print "invalid file type";
    exit 1;
}

close($in);
