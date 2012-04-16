package PrePAN::Model;
use strict;
use warnings;
use parent qw(Teng Exporter);

use PrePAN::Util;
use PrePAN::Config;

our @EXPORT = qw(model);
sub model { __PACKAGE__->new }

our $instance;
sub new {
    return $instance if $instance;

    my ($class, $args) = @_;
    $instance = $class->SUPER::new({
        connect_info => [
            (map { PrePAN::Config->param($_) } qw(dsn username password)),
            +{
                mysql_enable_utf8 => 1,
                on_connect_do     => [
                    "SET NAMES 'utf8'",
                    "SET CHARACTER SET 'utf8'"
                ],
            }
        ],
        %{$args || {}},
    });
}

sub uuid () {
    my $sth = model->dbh->prepare('select uuid_short() as uuid');
       $sth->execute;
    my $row = $sth->fetchrow_hashref;
       $row->{uuid};
}

sub create {
    my ($self, $table, $args) = @_;

    $args             ||= {};
    $args->{id}       ||= uuid;
    $args->{created}  ||= now;
    $args->{modified} ||= now;

    $self->insert($table => $args);
}

sub create_user {
    my ($self, $args) = @_;
    $self->create(user => {
        %{$args || {}},
        session_id => generate_session_id,
    });
}

sub create_oauth {
    my ($self, $args) = @_;
    $self->create(oauth => { %{$args || {}} });
}

sub create_module {
    my ($self, $args) = @_;
    $self->create(module => { %{$args || {}} });
}

sub create_review {
    my ($self, $args) = @_;
    $self->create(review => { %{$args || {}} });
}

sub create_vote {
    my ($self, $args) = @_;
    $self->create(vote => { %{$args || {}} });
}

sub modules {
    my ($self, $conditions, $options) = @_;
    my @modules = model->search('module', $conditions, $options)->all;

    if (@modules) {
        my %user_module_map = map { $_->user_id => $_ } @modules;
        my @users = model->search('user', {
            id => [ keys %user_module_map ],
        });

        for my $user (@users) {
            $user_module_map{$user->id}->user($user)
                if $user_module_map{$user->id};
        }
    }

    \@modules;
}

!!1;
