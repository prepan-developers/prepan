package t::PrePAN::Model::User;
use Project::Libs;
use Test::PrePAN::Model;

sub equals : Tests {
    my $self = shift;
    my $user = $self->create_test_user;

    ok $user->equals($user);
}

sub as_serializable : Tests {
    my $self = shift;
    my $user = $self->create_test_user;

    my $hash1 = $user->as_serializable;
    is ref $hash1, 'HASH';
    ok !exists $hash1->{notifications};

    my $hash2 = $user->as_serializable(with_notifications => 1);
    is ref $hash2, 'HASH';
    ok exists $hash2->{notifications};
}

sub register_oauth_id : Tests {
    my $self  = shift;
    my $user  = $self->create_test_user;
    my $oauth = $self->create_test_oauth;

    ok !$oauth->user_id;
    ok $user->register_oauth_id($oauth->short_id);
    is $user->id, $oauth->refetch->user_id;
}

sub oauth : Tests {
    my $self  = shift;

    diag 'getter';
    {
        my $user  = $self->create_test_user;
        my $oauth = $self->create_test_oauth(
            user_id => $user->id,
            service => 'github',
        );

        ok $user->oauth('github');
        is $user->oauth('github')->id, $oauth->id;
    }

    diag 'setter';
    {
        my $user  = $self->create_test_user;
        isnt $user->name, 'prepan@github';

        $user->oauth(github => {
            external_user_id => $self->model->uuid,
            info             => { login => 'prepan' },
        });

        is $user->oauth('github')->info->param('login'), 'prepan';
        is $user->name, 'prepan@github';
    }
}

sub modules : Tests {
    my $self    = shift;

    diag 'user has no modules';
    {
        my $user    = $self->create_test_user;
        my $modules = $user->modules;

        is ref $modules, 'ARRAY';
        is scalar @$modules, 0;
    }

    diag 'user has some modules';
    {
        my $user    = $self->create_test_user;
        my $module1 = $self->create_test_module(user_id => $user->id);
        my $module2 = $self->create_test_module(user_id => $user->id);
        my $modules = $user->modules;

        is ref $modules, 'ARRAY';
        is scalar @$modules, 2;
        ok $_->user->equals($user) for ($module1, $module2);
    }
}

sub timeline : Tests {
    my $self = shift;
    my $user = $self->create_test_user;

    ok     $user->timeline;
    isa_ok $user->timeline, 'PrePAN::Timeline';
}

__PACKAGE__->runtests;

!!1;
