package PrePAN::Timeline;
use Mouse;

has user => (
    is  => 'rw',
    isa => 'PrePAN::Model::Row::User',
);

has storage => (
    is      => 'ro',
    isa     => 'PrePAN::Redis',
    lazy    => 1,
    builder => 'build_storage',
);

no Mouse;
__PACKAGE__->meta->make_immutable;

use JSON;

use PrePAN::Util ();
use PrePAN::Redis;
use PrePAN::Timeline::Entry;

my $MAX_PER_USER  = 10;
my $DEFAULT_LIMIT = 30;

sub build_storage {
    my $self = shift;
    PrePAN::Redis->new;
}

sub key {
    my $self = shift;
    join ':', $self->user->short_id, 'timeline';
}

sub count {
    my $self = shift;
    $self->storage->count($self->key);
}

sub add {
    my ($self, $entry) = @_;

    if (ref $entry eq 'HASH') {
        $entry = PrePAN::Timeline::Entry->new($entry);
    }

    $self->storage->add(
        $self->key,
        PrePAN::Util::encode_json($entry->as_serializable),
    );

    if ($self->count > $MAX_PER_USER) {
        for (1 .. ($self->count > $MAX_PER_USER)) {
            $self->pop;
        }
    }

    $self->user->update({ unread_count => $self->user->unread_count + 1 });
    $entry;
}

sub pop {
    my $self = shift;
    $self->storage->pop($self->key);
}

sub entries {
    my ($self, $offset, $limit) = @_;
    $offset ||= 0;
    $limit  ||= $DEFAULT_LIMIT;

    my $start  = $offset * $limit;
    my $end    = ($offset + $limit) - 1;
    my $values = $self->storage->entries($self->key, $start, $end);

    my @entries;
    for my $value (@{$values || []}) {
        my $entry = PrePAN::Timeline::Entry->new(
            PrePAN::Util::decode_json($value || '{}')
        );

        push @entries, $entry;
    }

    @entries;
}

!!1;
