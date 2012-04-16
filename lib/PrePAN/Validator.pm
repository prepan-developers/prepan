package PrePAN::Validator;
use strict;
use warnings;
use parent qw(FormValidator::Lite);

use PrePAN::Data::Hash;

sub new {
    my ($class, $query) = @_;
    $class->SUPER::new($query || {});
}

sub query {
    my ($self, $query) = @_;
    $self->{query} = PrePAN::Data::Hash->new($query) if defined $query;
    $self->{query};
}

!!1;
