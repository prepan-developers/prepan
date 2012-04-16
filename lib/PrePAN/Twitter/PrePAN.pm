package PrePAN::Twitter::PrePAN;
use strict;
use warnings;
use parent qw(PrePAN::Twitter);

use PrePAN::Model;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;

    my $twitter = $self->twitter;
    if ($twitter) {
        $self->access_token($twitter->oauth('twitter')->access_token);
        $self->access_token_secret($twitter->oauth('twitter')->access_token_secret);
    }

    $self;
}

sub update {
    my ($self, $message) = @_;
    return if ($ENV{PREPAN_ENV} || '') ne 'production';
    $self->SUPER::update($message);
}

sub twitter {
    model->single('user', { name => 'prepanorg@twitter' });
}

!!1;
