package PrePAN::Qudo::Client;
use strict;
use warnings;

use base qw(Qudo);

use PrePAN::Config;

my $config = PrePAN::Config->current->{Qudo};

sub new {
    our $instance ||= do {
        my ($class, $args) = @_;

        $class->SUPER::new(
            databases     => $config->{databases},
            default_hooks => $config->{default_hooks},
            %{$args || {}},
        );
    };
}

!!1;
