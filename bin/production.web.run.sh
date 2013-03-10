#!/bin/sh

exec 2>&1
export PLACK_ENV=production
export PREPAN_ENV=production
export APPROOT=/var/www/prepan
cd $APPROOT || exit 1

exec setuidgid deployer carton exec -- \
     starman --port 8000 --workers=5 app.psgi
