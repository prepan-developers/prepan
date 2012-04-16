package t::PrePAN::App::Module;
use Project::Libs;
use Test::PrePAN::Model;

use PrePAN::App::Module;

use String::Random;

sub _create_no_user : Test(1) {
    my $self = shift;
    my $app = PrePAN::App::Module->new;

    my $module = $app->create;
    ok !$module;
}

sub _create_by_invalid_data : Test(10) {
    my $self = shift;
    my $user = $self->create_test_user;
    my $module;

    # name is null
    my $app = PrePAN::App::Module->new;
    $app->user($user);
    $module = $app->create;
    ok !$module;
    ok $app->validator->is_error('name');

    # name is too long
    $app = PrePAN::App::Module->new;
    $app->user($user);
    $app->name(String::Random->new->randregex('[a-z]{300}'));
    $module = $app->create;
    ok !$module;
    ok $app->validator->is_error('name');

    # name is like Acme::*
    $app = PrePAN::App::Module->new;
    $app->user($user);
    $app->name('Acme::' . time);
    $module = $app->create;
    ok !$module;
    ok $app->validator->is_error('name');

    # url is invalid
    $app = PrePAN::App::Module->new;
    $app->user($user);
    $app->name(String::Random->new->randregex('[a-z]{20}'));
    $app->url('aiueo');
    $module = $app->create;
    ok !$module;
    ok $app->validator->is_error('url');

    # summary is too long
    $app = PrePAN::App::Module->new;
    $app->user($user);
    $app->name(String::Random->new->randregex('[a-z]{20}'));
    $app->summary(String::Random->new->randregex('[a-z]{300}'));
    $module = $app->create;
    ok !$module;
    ok $app->validator->is_error('summary');
}

sub _create : Test(4) {
    my $self = shift;
    my $user = $self->create_test_user;
    my $module;

    # name is null
    my $app = PrePAN::App::Module->new;
    $app->user($user);
    my $name = String::Random->new->randregex('[a-z]{20}');
    $app->name($name);
    $module = $app->create;
    ok $module;
    is $module->name, $name;
    is $module->status, 'in review';
    is $module->user_id, $user->id;
}

__PACKAGE__->runtests;

!!1;
