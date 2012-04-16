package t::PrePAN::Timeline;
use Project::Libs;
use Test::PrePAN::Model;

use PrePAN::Timeline;
use PrePAN::Timeline::Entry;

sub timeline : Tests {
    my $self     = shift;
    my $user     = $self->create_test_user;
    my $module   = $self->create_test_module(
        user_id => $user->short_id,
    );
    my $timeline = PrePAN::Timeline->new({ user => $user });
    my $entry    = PrePAN::Timeline::Entry->new({
        subject_id => $user->short_id,
        object_id  => $module->short_id,
        verb       => 'review',
        info       => {},
    });

    $timeline->add($entry);
    is $timeline->count, 1;

    my @entries = $timeline->entries(0, 0);

    is        scalar(@entries), 1;
    isa_ok    $entries[0], 'PrePAN::Timeline::Entry';
    is_deeply $entries[0]->as_serializable, $entry;
}

__PACKAGE__->runtests;

!!1;
