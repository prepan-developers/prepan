#!/bin/sh
exec 2>&1
export PLACK_ENV=production
export PREPAN_ENV=production
export APPROOT=/home/app/www/PrePAN-Worker/current
export PERL=/home/app/perl5/perlbrew/perls/perl-5.14.2/bin/perl
cd $APPROOT || exit 1

CPANLIB=/home/app/www/PrePAN/shared

exec setuidgid app \
    carton exec -I$CPANLIB/lib/perl5 -- \
    $PERL script/worker.pl
