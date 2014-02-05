#!/usr/bin/env perl
use 5.14.0;
use warnings;
use File::Temp;
use File::Copy qw(move copy);
use Getopt::Long;
use File::Glob ':globally';
use Sys::Syslog;


=head1 SYNOPSIS

Script to take a directory containing a bunch of JPEG files, and convert them into
a x264 .mp4 video, in a timestamped filename, with a corresponding jpeg thumbnail.

=cut

my ($trial, $srcdir, $destdir);
openlog("motion-encode", "nofatal,pid", "local0");

GetOptions(
    "trial" => \$trial,
    "srcdir=s" => \$srcdir,
    "destdir=s" => \$destdir
);

eval {
    die "missing srcdir parameter\n" unless defined $srcdir;
    die "incorrect source dir: $srcdir\n" unless (-d $srcdir);
    die "missing destdir parameter\n" unless defined $destdir;
    die "incorrect dest dir: $srcdir\n" unless (-d $destdir);
};
if ($@) {
    syslog("warning", "Failed with: $@");
    die $@;
}

syslog("info", "started");
adjust_oom();

my $tmpdir = File::Temp->newdir;
my $output = output_name("mp4");
my $thumb_name = output_name("jpg");

my @srcfiles = sort grep { $_ !~ /lastsnap|snapshot/ } <$srcdir/*.jpg>;
die "Failed to find any source jepgs!\n" unless (scalar(@srcfiles) > 0);
syslog("info", "Number of source jpegs: " . scalar(@srcfiles));

my $thumbnail_idx = scalar(@srcfiles) > 6 ? 6 : -1;
# copy($srcfiles[$thumbnail_idx], join('/', $destdir, $thumb_name));
system("/usr/bin/convert", $srcfiles[$thumbnail_idx],
       "-resize", "640x240", "-unsharp", "1.5x1+0.7+0.02",
       "-quality", "80",
       join('/', $destdir, $thumb_name)
);
syslog("info", "created thumbnail $thumb_name");


my $i=0;
for my $f (@srcfiles) {
    my $dst = "$tmpdir/" . sprintf('frame%04d.jpg', $i);
    if ($trial) {
        copy($f, $dst);
    }
    else {
        move($f, $dst);
    }
    $i++;
}

# Let's save a miniature version for quick previewing:
my $minoutput = $output;
$minoutput =~ s/\.mp4/_mini\.mp4/;
system("nice /usr/bin/avconv -r 8 -i $tmpdir/frame\%04d.jpg -codec:v libx264 -profile:v main -pre:v libx264-faster  -b:v 80k -minrate 40k -maxrate 100k -bufsize 1000k -s 640x240 $destdir/$minoutput");
syslog("info", "encoded mini video $minoutput");

system("nice /usr/bin/avconv -r 2 -i $tmpdir/frame\%04d.jpg -codec:v libx264 -profile:v main -pre:v libx264-fast -crf 24 -minrate 100k -maxrate 400k -bufsize 1850k -r 2 $tmpdir/$output");
syslog("info", "encoded full video $output");
system("/usr/bin/qt-faststart $tmpdir/$output $destdir/$output");
syslog("info", "ran qt-faststart");


syslog("info", "finished");


sub output_name {
    my $extension = shift;
    my @t = localtime;
    # Ensure output filenames are the same even if called again later:
    state $base = sprintf('%04d-%02d-%02d_%02d-%02d-%02d',
        1900 + $t[5], $t[4] + 1, $t[3],
        $t[2], $t[1], $t[0],
    );
    return "$base.$extension";
}

# Adjust oom threshold to make us killed in preference to motion.
sub adjust_oom {
    open(my $fh, ">", "/proc/$$/oom_score_adj");
    print $fh "500\n";
    close $fh;
}

