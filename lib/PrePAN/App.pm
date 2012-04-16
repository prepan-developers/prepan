package PrePAN::App;
use Mouse;

has user => (
    is  => 'rw',
    isa => 'PrePAN::Model::Row::User',
);

has author => (
    is  => 'rw',
    isa => 'PrePAN::Model::Row::User',
);

has page => (
    is  => 'rw',
    isa => 'Maybe[Int]',
);

no Mouse;
__PACKAGE__->meta->make_immutable;

use Carp qw(croak);

use PrePAN::Util;
use PrePAN::Config;
sub config { PrePAN::Config->param($_[1]) }

use Class::Load qw(load_class);

sub user_is_author {
    my $self = shift;
    return if !$self->user;
    return if !$self->user->equals($self->author);
    !!1;
}

sub load {
    my ($self, $app, $params) = @_;

    return $self->{"_$app"} if $self->{"_$app"};

    my $app_class = join '::', __PACKAGE__, camelize $app;
    load_class $app_class;

    $params ||= {};
    $params->{user}   = $self->user   if $self->user;
    $params->{author} = $self->author if $self->author;
    $params->{page}   = $self->page || 1;

    $self->{"_$app"} = $app_class->new($params);
}

sub AUTOLOAD {
    my $app = our $AUTOLOAD;
       $app =~ s/.*:://o;

    {
        no strict   'refs';

        *{$AUTOLOAD} = sub {
            my $self = shift;
            $self->load($app) || croak "no such app: $app";
        };
    }

    goto &$AUTOLOAD;
}

!!1;
