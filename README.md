# Motion monitoring

These are a few config snippets and scripts I built around "motion", the open-source webcam
motion-detection software.

This configuration tells motion to just save jpegs rather than video; and then at the end
of motion detection, triggers a script which makes *two* videos and a thumbnail and puts
them in a www directory.

One video is low-res and sped-up, and the other is the full-size regular-speed one.

Another script is run from cron.daily, which removes old captures after five days.

## Requirements

You'll need to install avconv with libx264 support, and imagemagick's convert program.

I think most of the Perl libraries used tend to be in core these days, but you'll need
to aptitude install libfile-find-rule-perl libdatetime-perl

