package PrePAN::Pager;
use Mouse;

has has_next => (
    is  => 'rw',
    isa => 'Bool',
);

has has_prev => (
    is  => 'rw',
    isa => 'Bool',
);

has current_page => (
    is      => 'rw',
    isa     => 'Int',
    default => 1,
);

has entries => (
    is  => 'rw',
    isa => 'ArrayRef',
);

no Mouse;
__PACKAGE__->meta->make_immutable;

sub next_page {
    my $self = shift;
       $self->current_page + 1;
}

sub prev_page {
    my $self = shift;
    $self->current_page > 1 ? $self->current_page - 1 : 1;
}

!!1;


