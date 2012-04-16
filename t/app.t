package t::PrePAN::App;
use Project::Libs;
use Test::PrePAN::Model;

use PrePAN::App;

sub load : Tests {
    my $self = shift;
    my $app = PrePAN::App->new;

    ok $app->load('auth');
    isa_ok $app->load('auth'), 'PrePAN::App::Auth';

    isnt exception { $app->load('NoSuchApp') }, undef;
}

__PACKAGE__->runtests;

!!1;
