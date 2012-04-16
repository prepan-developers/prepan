package PrePAN::Model::Row::Review;
use strict;
use warnings;
use parent qw(PrePAN::Model::Row);

use PrePAN::Util;
use PrePAN::Model;

sub is_anonymouse { !!$_[0]->anonymouse   }
sub is_public     { !$_[0]->is_anonymouse }

sub is_viewable_by {
    my ($self, $user) = @_;

    if ($self->is_anonymouse) {
        return if !$user;
        return !!1 if $self->user_id == $user->id;
        return;
    }

    !!1;
}

sub user {
    my ($self, $user) = @_;
    $self->{__user} = $user if $user;
    return $self->{__user} if defined $self->{__user};
    $self->{__user} = model->single('user', { id => $self->user_id }) || '';
}

sub module {
    my ($self, $module) = @_;
    $self->{__module} = $module if $module;
    return $self->{__module} if defined $self->{__module};
    $self->{__module} = model->single('module', { id => $self->module_id }) || '';
}

sub formatted_comment {
    my $self = shift;
    format_markdown $self->comment;
}

!!1;
