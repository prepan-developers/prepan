#!/bin/sh

echo 'setup prepan db ... '
mysql -uroot -e 'DROP DATABASE IF EXISTS prepan; CREATE DATABASE prepan'
mysql -uroot prepan < db/schema.sql
mysql -uroot -e 'DROP DATABASE IF EXISTS qudo;'
qudo --db=qudo --user=root --rdbms=mysql --use_innodb
