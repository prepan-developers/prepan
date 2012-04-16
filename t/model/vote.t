package t::PrePAN::Model::Vote;
use Project::Libs;
use Test::PrePAN::Model;

sub create : Tests {
    my $self = shift;
    my $vote = $self->create_test_vote;

    ok     $vote;
    isa_ok $vote, 'PrePAN::Model::Row::Vote';
}

__PACKAGE__->runtests;

!!1;
