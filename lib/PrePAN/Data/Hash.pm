package PrePAN::Data::Hash;
use strict;
use warnings;

use parent qw(PrePAN::Data);

sub new {
    my ($class, $args) = @_;
    bless $args || {}, $class;
}

sub as_serializable {
    my $self = shift;
    + { %$self };
}

sub param {
    my $self = shift;
    if (@_ == 1) {
        my $key = shift;
        return $self->{$key};
    }
    elsif (@_ && @_ % 2 == 0) {
        my %args = @_;
        while (my ($key, $value) = each %args) {
            $self->{$key} = $value;
        }
        return $self;
    }
    else {
        keys %$self;
    }
}

sub AUTOLOAD {
    my $method = our $AUTOLOAD;
       $method =~ s/.*:://o;

    {
        no strict   'refs';

        *{$AUTOLOAD} = sub {
            my $self = shift;
               $self->{$method};
        };
    }

    goto &$AUTOLOAD;
}

!!1;
