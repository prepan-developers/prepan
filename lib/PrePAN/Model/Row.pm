package PrePAN::Model::Row;
use strict;
use warnings;
use parent qw(Teng::Row);

use PrePAN::Util;
use PrePAN::Model;

sub short_id {
    my $self = shift;
    encode_base58 $self->id;
}

sub search_with_users {
    my ($self, $table, $conditions, $options) = @_;
    my @rows = model->search($table, $conditions, $options)->all;

    if (@rows) {
        my %user_module_map = map { $_->user_id => $_ } @rows;
        my @users = model->search('user', {
            id => [ keys %user_module_map ],
        });

        for my $user (@users) {
            $user_module_map{$user->id}->user($user)
                if $user_module_map{$user->id};
        }
    }

    \@rows;
}

!!1;
