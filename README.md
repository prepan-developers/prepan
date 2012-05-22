# How to setup local development environment

You need to do three steps to develop PrePAN; setup local database, setup config file and install dependency.

## Local database setting

There is setup script for database setting.  please run below code at PrePAN root directory.

```sh
$ ./script/setup.sh
```

## Local config file setting

There is the example config file, which is local/development.eg.pl.  Copy and replace it.

```sh
$ cp local/development.eg.pl local/development.pl
```
And replace local/development.pl for your environment, for example twitter consumer key and so on.

## Install dependency
Run below at PrePAN root directory.

```sh
$ cpanm --installdeps .
```

# How to start local server
You can use plackup command to start local server.  Please run below at PrePAN root directory.

```sh
$ plackup
```

Enjoy Hacking!!

## Contact

You can ask [@prepanorg](http://twitter.com/prepanorg/) or [@shiba_yu36](http://twitter.com/shiba_yu36/) if you have a question.
