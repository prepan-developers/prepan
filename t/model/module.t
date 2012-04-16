package t::PrePAN::Model::Module;
use Project::Libs;
use Test::PrePAN::Model;

sub user : Tests {
    my $self   = shift;
    my $user   = $self->create_test_user;
    my $module = $self->create_test_module(user_id => $user->id);

    ok     $module->user;
    isa_ok $module->user, 'PrePAN::Model::Row::User';
}

sub is_owned_by : Tests {
    my $self   = shift;
    my $user   = $self->create_test_user;
    my $module = $self->create_test_module(user_id => $user->id);

    ok $module->is_owned_by($user);
}

sub reviews : Tests {
    my $self    = shift;
    my $module  = $self->create_test_module;
    my $review1 = $self->create_test_review(module_id => $module->id);
    my $review2 = $self->create_test_review(module_id => $module->id);
    my $reviews = $module->reviews;

    is ref $reviews, 'ARRAY';
    is scalar @$reviews, 2;
}

sub votes : Tests {
    my $self    = shift;
    my $module  = $self->create_test_module;
    my $vote1 = $self->create_test_vote(module_id => $module->id);
    my $vote2 = $self->create_test_vote(module_id => $module->id);
    my $votes = $module->votes;

    is ref $votes, 'ARRAY';
    is scalar @$votes, 2;
}

sub vote_by : Tests {
    my $self   = shift;
    my $user   = $self->create_test_user;
    my $module = $self->create_test_module;
    my $vote   = $module->vote_by($user);

    ok     $vote;
    isa_ok $vote, 'PrePAN::Model::Row::Vote';
    ok    !$module->vote_by($user);
}

__PACKAGE__->runtests;

!!1;
