package PrePAN::App::UserInfo;
use Mouse;
extends 'PrePAN::App::Base';

has 'url' => (
    is  => 'rw',
    isa => 'Str',
);

has 'pause_id' => (
    is  => 'rw',
    isa => 'Str',
);

has 'bitbucket' => (
    is  => 'rw',
    isa => 'Str',
);

has 'description' => (
    is  => 'rw',
    isa => 'Str',
);

has 'oauth' => (
    is  => 'rw',
    isa => 'PrePAN::Model::Row::Oauth',
);

no Mouse;
__PACKAGE__->meta->make_immutable;

use PrePAN::Model;

sub register {
    my $self   = shift;
    my $params = +{ map { $_ => $self->$_ } qw(url pause_id bitbucket description) };
    my %spec   = (
        url         => [[qw(HTTP_URL)]],
        pause_id    => [[qw(LENGTH 3 9)], [REGEXP => qr/[a-z]+/i]],
        bitbucket   => [[qw(LENGTH 3 30)], [REGEXP => qr/^\w+$/]],
        description => [[qw(LENGTH 1 255)]],
    );

    $self->validator->query($params);
    $self->validator->set_message_data($self->validation_messages->{'user.edit'});

    my $user;

    if ($self->validator->check(%spec)->has_error) {
        return;
    }
    else {
        $user = model->create_user({
            name => $self->oauth->name,
            %$params,
        });
        $self->oauth->update({ user_id => $user->id });
    }

    $user;
}

sub edit {
    my $self   = shift;
    my $params = +{ map { $_ => $self->$_ } qw(url pause_id bitbucket description) };
    my %spec   = (
        url         => [[qw(HTTP_URL)]],
        pause_id    => [[qw(LENGTH 3 9)],  [REGEXP => qr/^[A-Z]+$/]],
        bitbucket   => [[qw(LENGTH 3 30)], [REGEXP => qr/^\w+$/]],
        description => [[qw(LENGTH 1 255)]],
    );

    $self->validator->query($params);
    $self->validator->set_message_data($self->validation_messages->{'user.edit'});

    if ($self->validator->check(%spec)->has_error) {
        return;
    }
    else {
        $self->user->update($params);
    }

    !!1;
}

!!1;
