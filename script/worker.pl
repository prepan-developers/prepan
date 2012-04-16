#! /usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use PrePAN::Config;
use Qudo::Parallel::Manager;

my $config = PrePAN::Config->current->{Qudo};

my $manager = Qudo::Parallel::Manager->new(
    databases         => $config->{databases},
    default_hooks     => $config->{default_hooks},
    manager_abilities => $config->{workers},
    work_delay        => $config->{work_delay},
    max_workers       => $config->{max_workers},
    min_spare_workers => $config->{min_spare_workers},
    auto_load_worker  => 1,
    debug             => 1,
);
$manager->run; # start fork and work.
