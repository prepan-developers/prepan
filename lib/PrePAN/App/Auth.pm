package PrePAN::App::Auth;
use Mouse;
extends 'PrePAN::App::Base';

has 'twitter_user' => (
    is  => 'rw',
    isa => 'HashRef',
);

has 'twitter_access_token' => (
    is  => 'rw',
    isa => 'Str',
);

has 'twitter_access_token_secret' => (
    is  => 'rw',
    isa => 'Str',
);

has 'github_user' => (
    is  => 'rw',
    isa => 'HashRef',
);

has 'github_access_token' => (
    is  => 'rw',
    isa => 'Str',
);

no Mouse;
__PACKAGE__->meta->make_immutable;

use PrePAN::Util;
use PrePAN::Model;

sub register_twitter_user {
    my $self = shift;
    my $user = $self->user;
    my $oauth;

    my $twitter_data = {
        service             => 'twitter',
        external_user_id    => $self->twitter_user->{id},
        info                => $self->twitter_user,
        access_token        => $self->twitter_access_token,
        access_token_secret => $self->twitter_access_token_secret,
    };

    if ($user) {
        $oauth = $user->twitter($twitter_data);
    }
    else {
        $oauth = model->single('oauth', {
            external_user_id => $self->twitter_user->{id},
            service          => 'twitter',
        });

        if ($oauth) {
            $oauth->update($twitter_data);
        }
        else {
            $oauth = model->create_oauth($twitter_data);
        }

        $self->user($oauth->user) if $oauth->user;
    }

    if ($self->user) {
        $self->user->update({
            name       => $oauth->name,
            session_id => generate_session_id
        });
    }

    $oauth;
}

sub register_github_user {
    my $self = shift;
    my $user = $self->user;
    my $oauth;

    my $github_data = {
        service             => 'github',
        external_user_id    => $self->github_user->{id},
        info                => $self->github_user,
        access_token        => $self->github_access_token,
    };

    if ($user) {
        $oauth = $user->github($github_data);
    }
    else {
        $oauth = model->single('oauth', {
            external_user_id => $self->github_user->{id},
            service          => 'github',
        });

        if ($oauth) {
            $oauth->update($github_data);
        }
        else {
            $oauth = model->create_oauth($github_data);
        }

        $self->user($oauth->user) if $oauth->user;
    }

    if ($self->user) {
        $self->user->update({
            name       => $oauth->name,
            session_id => generate_session_id
        });
    }

    $oauth;
}

!!1;
