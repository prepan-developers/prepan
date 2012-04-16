package t::PrePAN::App::Auth;
use Project::Libs;
use Test::PrePAN::Model;

use PrePAN::App::Auth;

sub register_twitter_user : Tests {
    my $self = shift;
    my $app = PrePAN::App::Auth->new;
       $app->twitter_user({ id => 9999 });
       $app->twitter_access_token('access_token');
       $app->twitter_access_token_secret('access_token_secret');

    my $oauth = $app->register_twitter_user;

    ok     $oauth;
    isa_ok $oauth, 'PrePAN::Model::Row::Oauth';
    ok    !$oauth->user;
}

__PACKAGE__->runtests;

!!1;
