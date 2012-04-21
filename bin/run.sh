#!/bin/sh
exec 2>&1
export PLACK_ENV=production
export PREPAN_ENV=production
export APPROOT=/home/app/www/PrePAN/current
cd $APPROOT || exit 1

CPANLIB=/home/app/www/PrePAN/shared

exec setuidgid app \
    carton exec -I$CPANLIB/lib/perl5 -- $CPANLIB/bin/starman \
    --port 5555 \
    --workers=5 \
    app.psgi
