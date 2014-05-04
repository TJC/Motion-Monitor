#!/usr/bin/perl
use 5.16.0;
use warnings;
use IPC::Run qw(run);

my @addresses = qw(host1 host2 host3);

if (check_addresses()) {
    run("service motion stop");
}
else {
    run("service motion start");
}

sub check_addresses {
    for my $address (@addresses) {
        if (run("ping -qc 3 $address")) {
            return 1;
        }
    }
    return 0;
}
