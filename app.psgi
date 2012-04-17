BEGIN {
    $ENV{PREPAN_ENV} ||= ($ENV{PLACK_ENV} || '') eq 'production' ?
        'production' : 'development';
}

use strict;
use warnings;

use DBI;
use Plack::Builder;
use Plack::Session::Store::DBI;
use Plack::Session::State::Cookie;

use Path::Class;
use lib file(__FILE__)->dir->subdir('lib')->stringify;

use PrePAN;
use PrePAN::Web;
use PrePAN::Config;
use PrePAN::Util qw(root);

builder {
    enable 'Plack::Middleware::XFramework',
        framework => 'Amon2';

    enable 'Plack::Middleware::ReverseProxy';

    enable 'Plack::Middleware::Session',
        state => Plack::Session::State::Cookie->new(
            session_key => 'prepan',
            expires     => time() + (60 * 60 * 24 * 30),
        ),
        store => Plack::Session::Store::DBI->new(
            get_dbh => sub {
                DBI->connect(
                    map { PrePAN::Config->param($_) } qw(dsn username password)
                ) or die $DBI::errstr;
            }
        );

    # TODO: serve them via nginx
    enable 'Plack::Middleware::Static',
        path => qr{^/css|images|js|misc/},
        root => root->subdir('public');

    enable 'Plack::Middleware::Static',
        path => qr{^(?:/robots\.txt|/favicon.ico)$},
        root => root->subdir('public');

    PrePAN::Web->to_app;
};
