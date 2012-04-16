package t::PrePAN::Model::Review;
use Project::Libs;
use Test::PrePAN::Model;

sub is_viewable_by : Tests {
    my $self   = shift;
    my $user1  = $self->create_test_user;
    my $user2  = $self->create_test_user;
    my $review = $self->create_test_review(
        user_id    => $user1->id,
        anonymouse => 1,
    );

    ok  $review->is_anonymouse;
    ok !$review->is_public;
    ok !$review->is_viewable_by(undef);
    ok  $review->is_viewable_by($user1);
    ok !$review->is_viewable_by($user2);
}

__PACKAGE__->runtests;

!!1;
