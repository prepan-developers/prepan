#!/bin/sh
exec 2>&1
export PLACK_ENV=production
export PREPAN_ENV=production
export APPROOT=/home/app/www/PrePAN-Worker/current
cd $APPROOT || exit 1

exec setuidgid app /usr/bin/perl script/worker.pl
