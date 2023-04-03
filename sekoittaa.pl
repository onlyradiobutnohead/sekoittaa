#!/usr/bin/env perl

use strict;
use warnings;

use File::Basename;
use List::Util qw/shuffle/;

if ($#ARGV < 0) {
    print "Usage: sekoittaa.pl <wav_file> [output]\n";
    exit 1;
}

my $input_file = $ARGV[0];
my ($name, $path, $ext) = fileparse($input_file, qr/\.[^.]*/);

my $contents;
open(my $in, '<:raw', $input_file) 
    or die "Could not open file $input_file\n";
open(my $out, '>:raw', $#ARGV ? $ARGV[1] : "$name-sekoitted$ext")
    or die "Couldn't open output file: $!\n";

# identify file type
read($in, my $magic, 12);
if ($magic =~ m/RIFF[\x00-\xff]{4}WAVE/) {
    print $out $magic;
    # read till 'data' chunk

    while (read($in, my $chknmsz, 8)) { # handle each chunk
        print $out $chknmsz;
        my $chksz_u = unpack("L", substr($chknmsz, 4, 4));
        my $chknm = substr($chknmsz, 0, 4);
        print("$chknm: $chksz_u\n");
        read($in, my $chkdt, $chksz_u);

        if (substr($chknmsz, 0, 4) eq "data") {
            $chkdt = join('', shuffle(split(//, $chkdt)));
        }

        print $out $chkdt;
    }
} else {
    print "Invalid file type\n";
    exit 1;
}

close($in);
close($out);
