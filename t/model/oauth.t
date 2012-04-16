package t::PrePAN::Model::Oauth;
use Project::Libs;
use Test::PrePAN::Model;

sub user : Tests {
    my $self  = shift;
    my $oauth = $self->create_test_oauth;

    ok     $oauth;
    isa_ok $oauth, 'PrePAN::Model::Row::Oauth';
    ok    !$oauth->user;

    my $user = $self->create_test_user;
    $oauth->update({ user_id => $user->id });

    ok $oauth->user;
}

__PACKAGE__->runtests;

!!1;
