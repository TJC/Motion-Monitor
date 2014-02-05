#!/usr/local/modern/perl/bin/perl
use 5.12.2;
use strict;
use warnings;
use File::Find::Rule;
use DateTime;

my $basedir = shift or die "Pass directory on command line";
die "Directory ($basedir) does not exist."
    unless (-d $basedir);
my $age = shift or die "Pass age (in hours) on command line too.";
die "Invalid age ($age)" unless ($age and $age > 0 and $age < 1000);

my $dt = DateTime->now(time_zone => 'local');
$dt->subtract(hours => $age);
# say "Will wipe files earlier than: " . $dt->dmy . " " . $dt->hms;
my $time = $dt->epoch;

my $ffr = File::Find::Rule->new;
$ffr->file;
$ffr->mtime("<$time");
my @files = $ffr->in($basedir);

unlink($_) for @files;

