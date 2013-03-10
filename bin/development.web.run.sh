#!/bin/sh

exec 2>&1
export PLACK_ENV=development
export PREPAN_ENV=development
export APPROOT=/var/www/prepan
cd $APPROOT || exit 1

exec setuidgid app carton exec -- \
     starman --port 8000 --workers=5 app.psgi
