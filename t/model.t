package t::PrePAN::Model;
use Project::Libs;
use Test::PrePAN::Model;

use PrePAN::Model;

sub sigleton : Tests {
    my $self  = shift;
    my $model = PrePAN::Model->new;

    ok     $model;
    isa_ok $model, 'PrePAN::Model';
    is     $model, PrePAN::Model->new;
}

sub uuid : Tests {
    my $self = shift;
    my $uuid = $self->model->uuid;

    ok   $uuid;
    like $uuid, qr/^\d+$/;
}

sub create : Tests {
    my $self  = shift;
    my $model = PrePAN::Model->new;
    my $row   = $model->create(user => {
        name => time() . rand(),
    });

    ok     $row->id;
    like   $row->id, qr/^\d+$/;
    ok     $row->created;
    isa_ok $row->created,  'DateTime';
    ok     $row->modified;
    isa_ok $row->modified, 'DateTime',
}

sub create_user : Tests {
    my $self  = shift;
    my $model = PrePAN::Model->new;
    my $user  = $model->create_user({
        name => time() . rand(),
    });
    ok     $user;
    isa_ok $user, 'PrePAN::Model::Row::User';
    like   $user->session_id, qr/^[[:alnum:]]{40}$/;
}

__PACKAGE__->runtests;

!!1;
