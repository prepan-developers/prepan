package Test::PrePAN;
use utf8;
use strict;
use warnings;

use parent qw(Test::Class);

use Path::Class qw(dir);

sub import {
    my $class = shift;
    my ($call_pkg) = caller();

    utf8->import;
    strict->import;
    warnings->import;

    eval qq{
        package $call_pkg;
        use parent qw($class);
        use Test::More;
        use Test::Fatal;
    };
}

my $root = dir(__FILE__)->parent->parent->parent->parent;
sub root { $root }

!!1;
