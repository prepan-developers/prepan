package PrePAN::Twitter;
use strict;
use warnings;
use parent qw(Net::Twitter::Lite);

use PrePAN::Config;

my $config = PrePAN::Config->current->{Auth}{Twitter};

sub new {
    my $class = shift;
    $class->SUPER::new(
        consumer_key    => $config->{consumer_key},
        consumer_secret => $config->{consumer_secret},
        @_,
    );
}

!!1;
