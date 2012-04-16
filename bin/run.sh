#!/bin/sh
exec 2>&1
export PLACK_ENV=production
export PREPAN_ENV=production
export APPROOT=/home/app/www/PrePAN/current
#export PERL5LIB=/home/app/perl5/PrePAN/lib/perl5:/home/app/perl5/PrePAN/lib/perl5/i486-linux-gnu-thread-multi:PERL5LIB
cd $APPROOT || exit 1

exec setuidgid app \
    /usr/local/bin/starman \
    --port 5555 \
    --workers=5 \
    app.psgi
