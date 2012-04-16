package PrePAN::Model::Row::Module;
use strict;
use warnings;
use parent qw(PrePAN::Model::Row);

use HTML::Trim;

use PrePAN::Util;
use PrePAN::Model;

sub as_serializable {
    my $self = shift;

    +{
        user         => $self->user->as_serializable,
        name         => $self->name        || undef,
        url          => $self->url         || undef,
        summary      => $self->summary     || undef,
        synopsis     => $self->synopsis    || undef,
        description  => $self->description || undef,
        status       => $self->status,
        review_count => $self->review_count,
        created      => $self->created->epoch,
    };
}

sub path {
    my ($self, $path) = @_;
    sprintf '/module/%s%s', $self->short_id, $path || '';
}

sub user {
    my ($self, $user) = @_;
    $self->{__user} = $user if $user;
    return $self->{__user} if defined $self->{__user};
    $self->{__user} = model->single('user', { id => $self->user_id }) || '';
}

sub is_owned_by {
    my ($self, $user) = @_;
    return if !$user;
    $self->user_id == $user->id;
}

sub formatted_description {
    my $self = shift;
    format_markdown $self->description;
}

sub short_description {
    my ($self, $length, $rest) = @_;
    trim_html($self->description, $length, $rest || '');
}

sub reviews {
    my $self = shift;
    $self->{_reviews} ||= $self->search_with_users(
        review => { module_id => $self->id }
    );
}

sub votes {
    my ($self) = @_;
    $self->{_votes} ||= $self->search_with_users(
        vote => { module_id => $self->id }
    );
}

sub vote_by {
    my ($self, $user) = @_;

    return if !$user;
    return if model->single(vote => {
        module_id => $self->id,
        user_id   => $user->id
    });

    model->create_vote({
        module_id => $self->id,
        user_id   => $user->id
    });
}

!!1;
