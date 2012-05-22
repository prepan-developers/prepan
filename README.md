# How to setup local development environment

You need to setup local database and config file to develop PrePAN.

## local database setting

There is setup script for database setting.  please run below code at PrePAN root directory.

```sh
$ ./script/setup.sh
```

## local config file setting

There is the example config file, which is local/development.eg.pl.  Copy and replace it.

```sh
$ cp local/development.eg.pl local/development.pl
```
And replace local/development.pl for your environment, for example twitter consumer key and so on.


# How to start local server
You can use plackup command to start local server.  Please run below at PrePAN root directory.

```sh
$ plackup
```
