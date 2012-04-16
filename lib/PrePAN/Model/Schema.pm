package PrePAN::Model::Schema;
use strict;
use warnings;

use Teng::Schema::Declare;

use JSON;
use DateTime::Format::MySQL;

use PrePAN::Model::Row::User;
use PrePAN::Model::Row::Oauth;
use PrePAN::Data::Hash::Compact;

sub to_datetime {
    my $value = shift;
    my $datetime;

    if ($value ne '0000-00-00 00:00:00') {
        $datetime = DateTime::Format::MySQL->parse_timestamp($value);
    }

    $datetime;
}

sub from_datetime {
    my $datetime = shift;
    DateTime::Format::MySQL->format_datetime($datetime);
}

my %COMPACT_OPTIONS = (
    id          => { alias_for => 'i' },
    gravatar_id => { alias_for => 'g '},
    login       => { alias_for => 'l' },
    screen_name => { alias_for => 's' },
);

sub to_hash {
    my $value = shift || '{}';
    PrePAN::Data::Hash::Compact->new(decode_json $value, \%COMPACT_OPTIONS);
}

sub from_hash {
    my $hash = shift || {};
    encode_json(PrePAN::Data::Hash::Compact->new(
        $hash,
        \%COMPACT_OPTIONS
    )->as_serializable);
}

table {
    name 'user';
    pk 'id';
    columns qw(
        id
        name
        url
        description
        pause_id
        bitbucket
        session_id
        unread_count
        unread_from
        created
        modified
    );

    inflate 'unread_from' => \&to_datetime;
    deflate 'unread_from' => \&from_datetime;
    inflate 'created'     => \&to_datetime;
    deflate 'created'     => \&from_datetime;
    inflate 'modified'    => \&to_datetime;
    deflate 'modified'    => \&from_datetime;
};

table {
    name 'oauth';
    pk 'id';
    columns qw(
        id
        external_user_id
        service
        user_id
        info
        access_token
        access_token_secret
        created
        modified
    );

    inflate 'info'     => \&to_hash;
    deflate 'info'     => \&from_hash;
    inflate 'created'  => \&to_datetime;
    deflate 'created'  => \&from_datetime;
    inflate 'modified' => \&to_datetime;
    deflate 'modified' => \&from_datetime;
};

table {
    name 'module';
    pk 'id';
    columns qw(
        id
        user_id
        name
        url
        summary
        synopsis
        description
        status
        review_count
        created
        modified
    );

    inflate 'created'     => \&to_datetime;
    deflate 'created'     => \&from_datetime;
    inflate 'modified'    => \&to_datetime;
    deflate 'modified'    => \&from_datetime;
};

table {
    name 'review';
    pk 'id';
    columns qw(
        id
        module_id
        user_id
        comment
        anonymouse
        created
        modified
    );

    inflate 'created'  => \&to_datetime;
    deflate 'created'  => \&from_datetime;
    inflate 'modified' => \&to_datetime;
    deflate 'modified' => \&from_datetime;
};

table {
    name 'vote';
    pk   'id';
    columns qw(
        id
        module_id
        user_id
        created
        modified
    );

    inflate 'created'  => \&to_datetime;
    deflate 'created'  => \&from_datetime;
    inflate 'modified' => \&to_datetime;
    deflate 'modified' => \&from_datetime;
};

!!1;
