package PrePAN::Util;
use strict;
use warnings;

use JSON ();
use DateTime;
use Digest::SHA1;
use HTML::Trim;
use URI::Escape;
use Text::Markdown;
use Path::Class qw(dir);
use Encode::Base58::BigInt ();

use parent qw(Exporter);
our @EXPORT = qw(
    now
    generate_session_id
    root
    camelize
    encode_base58
    decode_base58
    trim
    trim_html
    format_markdown
    decode_json
    encode_json
    uri_escape
    uri_unescape
);

my $json = JSON->new->utf8->allow_blessed;
sub decode_json ($) {
    $json->decode(shift);
}

sub encode_json ($) {
    $json->encode(shift);
}

sub now (@) {
    my $time_zone = shift;
    DateTime->now(time_zone => 'UTC');
}

sub generate_session_id () {
    Digest::SHA1::sha1_hex(rand() . $$ . {} . time);
}

my $root = dir(__FILE__)->parent->parent->parent;
sub root () {
    $root;
}

sub camelize ($) {
    my $str   = shift;
    my @parts = split /_/, $str;
    join '', (map { ucfirst lc $_ } @parts);
}

sub encode_base58 ($) {
    Encode::Base58::BigInt::encode_base58(shift);
}

sub decode_base58 ($) {
    Encode::Base58::BigInt::decode_base58(shift);
}

sub trim ($) {
    my $text = shift || '';
       $text =~ s/^\s*//g;
       $text =~ s/\s*$//g;
       $text;
}

sub trim_html (@) {
    my ($text, $length, $rest) = @_;
    HTML::Trim::trim($text, $length, $rest || '...');
}

my $formatter;
sub format_markdown ($) {
    my $text = trim(shift || '');
       $text =~ s/<[^>]+>//g;

    $formatter ||= Text::Markdown->new;
    $formatter->markdown($text);
}

!!1;
