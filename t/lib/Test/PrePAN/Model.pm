package Test::PrePAN::Model;
use Test::PrePAN;
use PrePAN::Model ();

use Class::Accessor::Lite (
    rw => [qw(
        mysqld
        model
    )]
);

use DBI;
use Test::mysqld;
use Path::Class;
use Class::Load;

sub startup_model : Test(startup) {
    my $self = shift;
    my $mysqld = Test::mysqld->new(
        my_cnf => {
            'skip-networking' => '',
        }
    ) or plan skip_all => $Test::mysqld::errstr;

    my $dbh = DBI->connect(
        $mysqld->dsn . ';mysql_multi_statements=1',
    );
    $dbh->do('CREATE DATABASE prepan');
    $dbh->do('use prepan');
    my $sql = file(__FILE__)->dir->parent->parent->parent->parent->file('db/schema.sql')->slurp;
    $dbh->do($sql);

    $PrePAN::Model::instance = undef;   # PrePAN::Twitter::PrePAN make model before here
    my $model = PrePAN::Model->new({
        connect_info => [$mysqld->dsn(dbname => 'prepan', 'root', '' )]
    });

    $self->mysqld($mysqld);
    $self->model($model);
}

sub create_test_user {
    my ($self, %args) = @_;
    my $name = $args{name} || time() . rand();

    $self->model->create_user({
        name => $name,
    });
}

sub create_test_oauth {
    my ($self, %args) = @_;
    $args{external_user_id} ||= $self->model->uuid;
    $self->model->create_oauth(\%args);
}

sub create_test_module {
    my ($self, %args) = @_;
    $self->model->create_module(\%args);
}

sub create_test_review {
    my ($self, %args) = @_;
    $self->model->create_review(\%args);
}

sub create_test_vote {
    my ($self, %args) = @_;
    $self->model->create_vote(\%args);
}

!!1;
