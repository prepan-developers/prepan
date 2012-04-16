package t::PrePAN::Qudo::Client;
use Project::Libs;

use Test::PrePAN;
use PrePAN::Qudo::Client;

sub _new : Test(1) {
    my $client = PrePAN::Qudo::Client->new;
    ok $client;
}

__PACKAGE__->runtests;

!!1;
