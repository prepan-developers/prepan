package PrePAN::Data::Hash::Compact;
use strict;
use warnings;
use parent qw(
    Hash::Compact
    PrePAN::Data
);

sub as_serializable { $_[0]->compact }

!!1;
