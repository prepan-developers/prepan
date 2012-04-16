package PrePAN::Model::Row::Oauth;
use strict;
use warnings;
use parent qw(PrePAN::Model::Row);

use PrePAN::Util;
use PrePAN::Model;

sub name {
    my $self = shift;
    my $name;

    if ($self->service eq 'twitter') {
        $name = sprintf '%s@%s', $self->info->param('screen_name'), $self->service;
    }
    elsif ($self->service eq 'github') {
        $name = sprintf '%s@%s', $self->info->param('login'), $self->service;
    }

    ### XXX
    elsif ($self->service eq 'facebook') {
        $name = sprintf '%s@%s', $self->info->param('login'), $self->service;
    }

    $name;
}

sub url {
    my $self = shift;
    my $url;

    if ($self->service eq 'twitter') {
        $url = sprintf 'http://twitter.com/%s', $self->info->param('screen_name');
    }
    elsif ($self->service eq 'github') {
        $url = sprintf 'http://github.com/%s', $self->info->param('login');
    }

    ### XXX
    elsif ($self->service eq 'facebook') {
        $url = sprintf '%s@%s', $self->info->param('login'), $self->service;
    }

    $url;
}

sub favicon {
    my $self = shift;
    my $favicon = 'http://www.google.com/s2/favicons?domain=';

    if ($self->service eq 'twitter') {
        $favicon .= 'twitter.com';
    }
    elsif ($self->service eq 'github') {
        $favicon .= 'github.com';
    }
    elsif ($self->service eq 'facebook') {
        $favicon .= 'facebook.com';
    }

    $favicon;
}

sub profile_image {
    my $self = shift;
    my $url;

    if ($self->service eq 'twitter') {
        $url = sprintf 'http://api.twitter.com/1/users/profile_image/%s',
            $self->external_user_id;

    }
    elsif ($self->service eq 'github') {
        $url = sprintf 'http://www.gravatar.com/avatar/%s?s=48',
            $self->info->param('gravatar_id'),
    }

    $url;
}

sub profile_image_mini {
    my $self = shift;
    my $url;

    if ($self->service eq 'twitter') {
        $url = sprintf 'http://api.twitter.com/1/users/profile_image/%s?size=mini',
            $self->external_user_id;

    }
    elsif ($self->service eq 'github') {
        $url = sprintf 'http://www.gravatar.com/avatar/%s?s=24',
            $self->info->param('gravatar_id'),
    }

    $url;
}

sub profile_image_bigger {
    my $self = shift;
    my $url;

    if ($self->service eq 'twitter') {
        $url = sprintf 'http://api.twitter.com/1/users/profile_image/%s?size=bigger',
            $self->external_user_id;

    }
    elsif ($self->service eq 'github') {
        $url = sprintf 'http://www.gravatar.com/avatar/%s?s=73',
            $self->info->param('gravatar_id'),
    }

    $url;
}

sub user {
    my ($self, $user) = @_;
    my $key = "__user" . (defined $self->user_id ? $self->user_id : '');

    $self->{$key} = $user if $user;
    return $self->{$key} if defined $self->{$key};

    $self->{$key} = (
        $self->user_id && model->single('user', { id => $self->user_id })
    ) || '';
}

!!1;
