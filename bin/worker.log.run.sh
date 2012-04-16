#!/bin/sh
exec 2>&1
exec setuidgid app /usr/bin/multilog t ./main
