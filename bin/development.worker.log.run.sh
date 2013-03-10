#!/bin/sh

exec 2>&1
exec setuidgid deployer /usr/bin/multilog t ./main
