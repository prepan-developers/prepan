package PrePAN::Model::Row::User;
use strict;
use warnings;
use parent qw(PrePAN::Model::Row);

use PrePAN::Util;
use PrePAN::Model;
use PrePAN::Timeline;

sub equals {
    my ($self, $user) = @_;
    return if !$user;
    $self->id == $user->id;
}

sub as_serializable {
    my ($self, %options) = @_;
    my @notifications;

    if ($options{with_notifications}) {
        my $unread_from = $options{unread_from} || 0;
        my @entries     = grep {
            $unread_from < $_->created->epoch;
        } $self->timeline->entries(0, 10);

        for my $entry (@entries) {
            push @notifications, $entry->as_inflated_serializable;
        }
    }

    +{
        short_id             => $self->short_id,
        name                 => $self->name,
        profile_image        => $self->profile_image,
        profile_image_mini   => $self->profile_image_mini,
        profile_image_bigger => $self->profile_image_bigger,
        home                 => 'http://prepan.org' . $self->path,
        url                  => $self->url || undef,
        description          => $self->description || undef,
        pause_id             => $self->pause_id || undef,
        unread_count         => $self->unread_count,
        unread_from          => $self->unread_from ? $self->unread_from->epoch : undef,
        $options{with_notifications} ?
            (notifications => \@notifications) : (),
    };
}

sub external_service {
    my $self = shift;
    my ($external_service) = $self->name =~ /\@(twitter|github|facebook)$/;
    $external_service || '';
}

sub is_twitter_user {
    my $self = shift;
    $self->external_service eq 'twitter';
}

sub is_github_user {
    my $self = shift;
    $self->external_service eq 'github';
}

sub is_facebook_user {
    my $self = shift;
    $self->external_service eq 'facebook';
}

sub profile_image {
    my $self = shift;
    my $url;

    if ($self->is_twitter_user) {
        $url = $self->twitter->profile_image;
    }
    elsif ($self->is_github_user) {
        $url = $self->github->profile_image;
    }

    $url;
}

sub profile_image_mini {
    my $self = shift;
    my $url;

    if ($self->is_twitter_user) {
        $url = $self->twitter->profile_image_mini;
    }
    elsif ($self->is_github_user) {
        $url = $self->github->profile_image_mini;
    }

    $url;
}

sub profile_image_bigger {
    my $self = shift;
    my $url;

    if ($self->is_twitter_user) {
        $url = $self->twitter->profile_image_bigger;
    }
    elsif ($self->is_github_user) {
        $url = $self->github->profile_image_bigger;
    }

    $url;
}

sub path {
    my ($self, $path) = @_;
    sprintf '/user/%s%s', $self->short_id, $path || '';
}

sub register_oauth_id {
    my ($self, $oauth_id) = @_;
    my $oauth = model->single(oauth => { id => decode_base58 $oauth_id });
       $oauth && $oauth->update({ user_id => $self->id });
}

sub twitter {
    my ($self, $data) = @_;
    return $self->{__twitter} if $self->{__twitter};
    $self->{__twitter} = $self->oauth('twitter', $data);
}

sub github {
    my ($self, $data) = @_;
    return $self->{__github} if $self->{__github};
    $self->{__github} = $self->oauth('github', $data);
}

sub oauth {
    my ($self, $service, $data) = @_;
    my $oauth;

    if ($data) {
        $oauth ||= model->single(oauth => {
            external_user_id => $data->{external_user_id},
            service          => $service,
        }) || model->create_oauth({
            service => $service,
            user_id => $self->id,
        });

        $oauth->update({
            user_id             => $self->id,
            external_user_id    => $data->{external_user_id},
            info                => $data->{info},
            access_token        => $data->{access_token},
            access_token_secret => $data->{access_token_secret} || '',
        });

        if ($oauth->name && $self->name ne $oauth->name) {
            $self->update({ name => $oauth->name });
        }
    }

    $self->{"__oauth_$service"} ||= $oauth || model->single('oauth', {
        user_id => $self->id,
        service => $service,
    });
}

sub modules {
    my ($self, $offset, $limit) = @_;
    my $key = join ':', '__modules', $offset || '', $limit || '';
    return $self->{__modules} if defined $self->{__modules};

    my @modules = model->search(module => {
        user_id => $self->id,
    }, {
        order_by => 'created desc',
        offset   => $offset,
        limit    => $limit,
    })->all;

    for my $module (@modules) {
        $module->user($self);
    }

    $self->{__modules} = [@modules];
}

sub timeline {
    my $self = shift;
    $self->{__timeline} ||= PrePAN::Timeline->new({ user => $self });
}

!!1;
