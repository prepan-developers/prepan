package PrePAN::Web;
use utf8;
use strict;
use warnings;

use File::Spec;
use Tiffany;
use Template::Stash::ForceUTF8;
use Template::Provider::Encoding;

use parent qw(
    PrePAN
    Amon2::Web
);

use PrePAN::Util;
use PrePAN::App;
use PrePAN::Model;
use PrePAN::Config;
use PrePAN::Web::Dispatcher;

__PACKAGE__->load_plugins(qw(
    Web::NoCache
    Web::CSRFDefender
));

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ($c) = @_;

        $c->user && $c->app->user($c->user);
        $c->app->page($c->req->param('page'));

        if ($c->req->path =~ m{^/user/([[:alnum:]]{10})}o) {
            $c->data(author_id => $1);
            $c->author && $c->app->author($c->author);
        }

        if ($c->req->path =~ m{^/module/([[:alnum:]]{10})}o) {
            $c->data(module_id => $1);
        }

        $c->data(view_params => +{
            c                       => $c,
            config                  => $c->config,
            req                     => $c->req,
            app                     => $c->app    || '',
            user                    => $c->user   || '',
            author                  => $c->author || '',
            module                  => $c->module || '',
            signin_with_twitter_url => $c->signin_with_twitter_url,
            signin_with_github_url  => $c->signin_with_github_url,
            csrf_token              => $c->get_csrf_defender_token || '',
        });
    },
);

__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ($c, $res) = @_;

        $res->header('X-Content-Type-Options' => 'nosniff');
        $res->header('X-Frame-Options' => 'DENY');

        if ($c->req->path_info =~ m{/auth/(?:twitter|github)/authenticate}) {
            $c->session->set(backurl => $c->req->param('backurl'))
                if ($c->req->param('backurl') || '') !~ m{^https?://[^/]+/auth};
        }
    },
);

sub dispatch {
    PrePAN::Web::Dispatcher->dispatch($_[0])
            or die "response is not generated";
}

sub user {
    my $self = shift;
    return $self->data('user') if defined $self->data('user');

    my $user;

    if (my $session_id = $self->session->get('prepan')) {
        $user = model->single(user => { session_id => $session_id });
    }

    $self->data(user => $user || '');
}

sub author {
    my $self = shift;

    return if !$self->data('author_name') && !$self->data('author_id');
    return $self->data('author') if defined $self->data('author');

    my $author;

    if (my $name = $self->data('author_name')) {
        $author = model->single(user => { name => $name });
    }
    elsif (my $id = $self->data('author_id')) {
        $author = model->single(user => { id => decode_base58 $id });
    }

    $self->data(author => $author || '');
}

sub check_user {
    my $self = shift;

    if (!$self->user) {
        $self->redirect('/');
        return;
    }

    !!1;
}

sub check_author {
    my $self = shift;

    if (!$self->author) {
        $self->res_404;
        return;
    }

    !!1;
}

sub check_privilege {
    my $self = shift;

    if (!$self->check_author || !$self->user->equals($self->author)) {
        $self->res_403;
        return;
    }

    !!1;
}

sub module {
    my $self = shift;

    return if !$self->data('module_id') && !$self->req->param('module_id');
    return $self->data('module') if defined $self->data('module');

    my $short_id = $self->data('module_id') || $self->req->param('module_id');
    my $module   = model->single(module => { id => decode_base58($short_id) });

    $self->data(module => $module || '');
}

sub check_module {
    my $self = shift;
    if (!$self->module) {
        $self->res_404;
        return;
    }

    !!1;
}

sub check_module_owner {
    my $self = shift;
    return if !$self->check_module;

    if (!$self->module->is_owned_by($self->user)) {
        $self->res_403;
        return;
    }

    !!1;
}

sub oauth {
    my $self = shift;
    return if !$self->session->get('oauth_id');
    return $self->data('oauth') if defined $self->data('oauth');

    my $short_id = $self->session->get('oauth_id');
    my $oauth    = model->single(oauth => { id => decode_base58($short_id) });

    $self->data(oauth => $oauth || '');
}

sub check_oauth {
    my $self = shift;

    if (!$self->oauth) {
        $self->res_404;
        return;
    }

    !!1;
}

sub signin_with_twitter_url {
    my $self = shift;

    sprintf '/auth/twitter/authenticate?backurl=%s',
        uri_escape($self->req->uri);
};

sub signin_with_github_url {
    my $self = shift;

    sprintf '/auth/github/authenticate?backurl=%s',
        uri_escape($self->req->uri);
}

sub res_403 {
    my $self    = shift;
    my $content = '403 forbidden';

    $self->create_response(
        403,
        [
            'Content-Type' => 'text/html; charset=utf-8',
            'Content-Length' => length($content),
        ],
        [$content]
    );
}

sub res_json {
    my ($self, $data) = @_;
    my $content = encode_json $data;

    $self->create_response(
        200,
        [
            'Content-Type' => 'application/json; charset=utf-8',
            'Content-Length' => length($content),
        ],
        [$content]
    );
}

sub render_text {
    my ($self, $text) = @_;

    $self->create_response(
        200,
        [
            'Content-Type' => 'text/html; charset=utf-8',
            'Content-Length' => length($text || ''),
        ],
        [$text],
    );
}

sub render {
    my ($self, $tmpl, $params) = @_;
    $tmpl .= '.tt' if $tmpl !~ /\.(?:tt|html)$/;
    my %params = (%{$self->data('view_params') || {}}, %{$params || {}});

    $self->SUPER::render($tmpl, \%params)
}

{
    my $view_conf = PrePAN::Config->param('view') || {};

    if (!exists $view_conf->{path}) {
        $view_conf->{path} = root->subdir('views');
    }

    my $include_path = root->subdir('views')->stringify;
    my $view = Tiffany->load(TT => {
        INCLUDE_PATH   => [ $include_path ],
        PRE_PROCESS    => [qw(macro.tt)],
        STASH          => Template::Stash::ForceUTF8->new,
        LOAD_TEMPLATES => [
            Template::Provider::Encoding->new(
                INCLUDE_PATH => $include_path,
            ),
        ],
        FILTERS        => {
            trim_html  => [
                sub {
                    my ($context, $length, $rest) = @_;
                    return sub {
                        my $string = shift;
                        trim_html($string, $length, $rest || '...');
                    }
                },
                1,
            ],
        },

        %$view_conf
    });

    sub create_view { $view }
}

!!1;
