package PrePAN::App::Base;
use Mouse;
use PrePAN::Qudo::Client;

has 'user' => (
    is  => 'rw',
    isa => 'PrePAN::Model::Row::User',
);

has 'author' => (
    is  => 'rw',
    isa => 'PrePAN::Model::Row::User',
);

has page => (
    is  => 'rw',
    isa => 'Maybe[Int]',
);

has 'validator' => (
    is      => 'ro',
    isa     => 'PrePAN::Validator',
    lazy    => 1,
    builder => 'build_validator',
);

has 'validation_messages' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    builder => 'build_validation_messages',
);

has 'job_queue' => (
    is      => 'ro',
    isa     => 'PrePAN::Qudo::Client',
    lazy    => 1,
    default => sub { PrePAN::Qudo::Client->new },
);

no Mouse;
__PACKAGE__->meta->make_immutable;

sub offset_for {
    my ($self, $limit) = @_;
    my $page = $self->page || 1;
       $page = 1 if $page <= 1;

    ($page - 1) * $limit;
}

use PrePAN::Util;
use PrePAN::Validator;
PrePAN::Validator->load_constraints(qw/URL/);

sub build_validator {
    my $self = shift;
    my $validator = PrePAN::Validator->new;
       $validator->load_function_message('en');
       $validator;
}

use YAML;
sub build_validation_messages {
    my $self = shift;
    YAML::LoadFile(root->subdir('config/validation')->file('messages.yml'));
}

!!1;
