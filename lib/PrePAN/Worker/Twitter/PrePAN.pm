package PrePAN::Worker::Twitter::PrePAN;
use strict;
use warnings;

use parent qw(Qudo::Worker);

sub work {
    my ($self , $job ) = @_;

    my $arg = $job->arg;
    my $message = $arg->{message};

    if (defined $message) {
        require PrePAN::Twitter::PrePAN;
        eval { PrePAN::Twitter::PrePAN->new->update($message) };
        warn $@ if $@;
        $job->abort if $@;
    }

    $job->completed();                  # or $job->abort
}

sub max_retries { 2 }

sub retry_delay { 10 }

1;
