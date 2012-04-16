package PrePAN::Model::Row::Vote;
use strict;
use warnings;
use parent qw(PrePAN::Model::Row);

sub user {
    my ($self, $user) = @_;
    $self->{__user} = $user if $user;
    return $self->{__user} if defined $self->{__user};
    $self->{__user} = model->single('user', { id => $self->user_id }) || '';
}

!!1;
