package PrePAN::App::Module;
use Mouse;
extends 'PrePAN::App::Base';

has 'name' => (
    is  => 'rw',
    isa => 'Str',
);

has 'url' => (
    is  => 'rw',
    isa => 'Str',
);

has 'summary' => (
    is  => 'rw',
    isa => 'Str',
);

has 'synopsis' => (
    is  => 'rw',
    isa => 'Str',
);

has 'description' => (
    is  => 'rw',
    isa => 'Str',
);

has 'status' => (
    is  => 'rw',
    isa => 'Str',
);

has 'comment' => (
    is  => 'rw',
    isa => 'Str',
);

has 'anonymouse' => (
    is  => 'rw',
    isa => 'Int|Str',
);

has 'review_id' => (
    is  => 'rw',
    isa => 'Str',
);

has 'module' => (
    is  => 'rw',
    isa => 'PrePAN::Model::Row::Module',
);

has 'twitter' => (
    is      => 'ro',
    isa     => 'PrePAN::Twitter::PrePAN',
    lazy    => 1,
    default => sub { PrePAN::Twitter::PrePAN->new },
);

no Mouse;
__PACKAGE__->meta->make_immutable;

use PrePAN::Util;
use PrePAN::Model;
use PrePAN::Pager;
use PrePAN::Twitter::PrePAN;

my %spec   = (
    name    => [
        'NOT_NULL',
        [qw(LENGTH 1 255)],
        [MATCH => sub { $_[0] !~ qr{^Acme::}i }],
    ],
    url     => [[qw(HTTP_URL)]],
    summary => [[qw(LENGTH 1 255)]],
    status  => [[REGEXP => qr/(in review|shipped|finished)/]],
);

sub create {
    my $self   = shift;

    return if !$self->user;

    my $params = +{
        map {
            $_ => $self->$_ || ''
        } qw(name url summary synopsis description)
    };
    my $module;

    $self->validator->query($params);
    $self->validator->set_message_data($self->validation_messages->{'module.edit'});

    if ($self->validator->check(%spec)->has_error) {
        return;
    }
    else {
        $params->{user_id} = $self->user->id;
        $module = model->create_module($params);
    }

    eval {
        my $message = sprintf '%s by %s - http://prepan.org%s #prepan',
            $module->name,
            $self->user->name,
            $module->path;

        $self->job_queue->enqueue(
            'PrePAN::Worker::Twitter::PrePAN',
            { arg => {message => $message} },
        );
    };
    warn $@ if $@;

    $module;
}

sub edit {
    my $self   = shift;

    return if !$self->module;
    return if !$self->module->is_owned_by($self->user);

    my $params = +{
        map {
            $_ => $self->$_ || ''
        } qw(name url summary synopsis description status)
    };

    $self->validator->query($params);
    $self->validator->set_message_data($self->validation_messages->{'module.edit'});

    if ($self->validator->check(%spec)->has_error) {
        return;
    }
    else {
        $self->module->update($params);
    }

    $self->module;
}

sub recent_modules {
    my ($self, $limit) = @_;
    my $offset = $self->offset_for($limit);
    my $key = sprintf "_recent_modules_%s_%s", $offset, $limit;

    return $self->{$key} if defined $self->{$key};

    my $pager   = PrePAN::Pager->new({ current_page => $self->page });
    my $modules = model->modules({
        status => { '!=', 'finished' },
    }, {
        order_by => 'created desc',
        offset   => $offset,
        limit    => $limit + 1,
    });

    if (scalar @$modules > $limit) {
        $pager->has_next(1);
        $modules = [ splice @$modules, 0, $limit ];
    }

    $pager->has_prev(1) if $offset / $limit;
    $pager->entries($modules);

    $self->{$key} = $pager;
}

sub post_review {
    my $self = shift;

    return if !$self->module;

    my $review = model->create_review({
        comment    => $self->comment,
        user_id    => $self->user->id,
        module_id  => $self->module->id,
        anonymouse => $self->anonymouse ? 1 : 0,
    });

    my $review_count = $self->module->review_count || 0;
    $self->module->update({ review_count => $review_count + 1 });

    my %seen;
    my @users = ($self->module->user);
    push @users, map {
        $_->user
    } grep {
        !$seen{$_->user->id}++
    } @{$self->module->reviews || []};

    for my $user (@users) {
        next if $self->user->id == $user->id;

        $user->timeline->add({
            subject_id => $self->anonymouse ? undef : $self->user->short_id,
            object_id  => $self->module->short_id,
            verb       => 'comment',
            info       => {
                content => $review->comment,
                created => $review->created.q(),
            },
        });
    }

    $review;
}

sub delete_review {
    my $self   = shift;
    my $review = model->single(
        review => { id => decode_base58($self->review_id) }
    ) || return;
    my $user   = $review->user || return;

    if ($user->equals($self->user)) {
        if (my $module = $review->module) {
            my $review_count = $module->review_count || 1;
            $module->update({ review_count => $review_count - 1 });
        }

        $review->delete;
    }
}

sub vote {
    my $self = shift;

    return if !$self->module;
    return if !$self->user;

    if (my $vote = $self->module->vote_by($self->user)) {
        $self->module->user->timeline->add({
            subject_id => $self->user->short_id,
            object_id  => $self->module->short_id,
            verb       => 'vote',
            info       => {
                created => $vote->created.q(),
            },
        });

        return $vote;
    }
}

!!1;
