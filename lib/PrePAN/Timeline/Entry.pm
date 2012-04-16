package PrePAN::Timeline::Entry;
use Mouse;

has subject_id => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);

has object_id => (
    is  => 'rw',
    isa => 'Str',
);

has verb => (
    is  => 'rw',
    isa => 'Str',
);

has info => (
    is  => 'rw',
    isa => 'Maybe[HashRef]',
);

no Mouse;
__PACKAGE__->meta->make_immutable;

use DateTime;

use PrePAN::Util;
use PrePAN::Model;

sub as_serializable {
    my $self = shift;

    +{
        subject_id => $self->subject_id,
        object_id  => $self->object_id,
        verb       => $self->verb,
        info       => $self->info || {},
    };
}

sub as_inflated_serializable {
    my $self = shift;

    +{
        subject     => $self->subject ? $self->subject->as_serializable : {},
        object      => $self->object->as_serializable,
        object_type => $self->object_type,
        verb        => $self->verb,
        created     => $self->created->epoch,
    }
}

sub subject {
    my ($self, $subject) = @_;
    $self->{__subject} = $subject if defined $subject;
    return $self->{__subject} if defined $self->{__subject};
    $self->{__subject} = $self->subject_id ? (
        model->single('user', {
            id => decode_base58 $self->subject_id
        }) || ''
    ) : '';
}

sub object_type {
    my $self = shift;

    +{
        create  => 'module',
        review  => 'module',
        comment => 'module',
        vote    => 'module',
    }->{$self->verb};
}

sub object {
    my ($self, $object) = @_;
    $self->{__object} = $object if defined $object;
    return $self->{__object} if defined $self->{__object};

    $self->{__object} = model->single($self->object_type, {
        id => decode_base58 $self->object_id
    }) || '';
}

sub created {
    my $self = shift;
    return $self->{_created} if defined $self->{_created};
    my ($year, $month, $day, $hour, $minute, $second) =
        $self->info->{created} =~ /(\d{4})-(\d{2})-(\d{2})(?:T| )?(\d{2}):(\d{2}):(\d{2})/;
    $self->{_created} = DateTime->new(
        year   => $year,
        month  => $month,
        day    => $day,
        hour   => $hour,
        minute => $minute,
        second => $second,
    )->set_time_zone('UTC');
}

!!1;
