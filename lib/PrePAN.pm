package PrePAN;
use strict;
use warnings;
use utf8;

use parent qw(Amon2);
our $VERSION = '0.02';

use PrePAN::Config;

sub data {
    my ($self, $key, $value) = @_;
    $self->{data} ||= {};
    $self->{data}{$key} = $value if defined $value;
    $self->{data}{$key};
}

sub app {
    my $self = shift;
    return $self->data('app') if defined $self->data('app');

    $self->data(app => PrePAN::App->new);
};


{
    package PrePAN::Config::Adaptor;
    use Tie::Hash;
    sub TIEHASH {
        my ($class, %args) = @_;
        bless \%args, $class;
    }

    sub FETCH {
        my ($self, $key) = @_;
        PrePAN::Config->param($key);
    }

    for my $method(qw(STORE FIRSTKEY NEXTKEY EXISTS DELETE CLEAR SCALAR)) {
        no strict 'refs';
        *{__PACKAGE__ . "\::$method"} = sub {};
    }
}

tie my %config, 'PrePAN::Config::Adaptor';

sub load_config { \%config }
sub config      { \%config }

!!1;
