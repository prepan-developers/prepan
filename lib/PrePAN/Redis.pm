package PrePAN::Redis;
use Mouse;

has storage => (
    is      => 'ro',
    isa     => 'RedisDB',
    lazy    => 1,
    builder => 'build_storage',
);

no Mouse;
__PACKAGE__->meta->make_immutable;

use RedisDB;
use PrePAN::Config;

our $redis;
sub build_storage {
    my $self = shift;
    $redis ||= RedisDB->new(%{PrePAN::Config->param('redis')});
}

sub count {
    my ($self, $key) = @_;
    $self->storage->llen($key);
}

sub add {
    my ($self, $key, $value) = @_;
    $self->storage->lpush($key, $value);
}

sub pop {
    my ($self, $key) = @_;
    $self->storage->rpop($key);
}

sub entries {
    my ($self, $key, $start, $end) = @_;
    $self->storage->lrange($key, $start, $end);
}


!!1;
