#!/usr/bin/perl
# An amazingly simple script to view the captured stuff; really worth doing properly later.
use 5.14.0;
use warnings;
our $BASEURL="motion";

chdir "/var/www/motion";

print "Content-Type: text/html\n";
print "Cache-Control: no-cache\n";
print "\n";

eval {
  mainbody();
};
if ($@) {
  print "Error: $@\n";
  exit;
}

sub mainbody {
  my @thumbs = reverse sort grep { ! /camera\d/ } <*.jpg>;
  header();
  my $i = 0;
  while ($i++ < 12 && @thumbs) {
      showthumb(shift @thumbs);
  }
  footer();
}

sub header {
print "
<!DOCTYPE html>
<html>
<head>
<title>CubieCam</title>
<style>
.item {
  width: 660px;
  border: 1px solid grey;
  border-radius: 5px;
  margin-bottom: 5px;
  padding: 10px;
}
</style>
</head>
<body>
<div class='item'>
Current snapshot: 
<a href='$BASEURL/camera1.jpg'>Camera 1</a>
<a href='$BASEURL/camera2.jpg'>Camera 2</a>
<a href='$BASEURL/camera3.jpg'>Camera 3</a>
</div>
";
}

sub footer {
    print "</body></html>\n";
}

sub showthumb {
    my $file = shift;
    my $name = $file;
    my ($date, $time) = split('_', $file);
    $time =~ s/\-/:/g;

    my ($minivid, $fullvid);
    $fullvid = $file;
    $fullvid =~ s/\.jpg/\.mp4/;

    $minivid = $fullvid;
    $minivid =~ s/\.mp4/_mini\.mp4/;

    print "<div class='item'>$date $time<br><img src='$BASEURL/$file' width='640' height='240'><br>\n";
    print "Video: <a href='$BASEURL/$minivid'>Fast preview</a>;\n";
    print "<a href='$BASEURL/$fullvid'>Full size</a>\n";
    print "</div>\n";

}
