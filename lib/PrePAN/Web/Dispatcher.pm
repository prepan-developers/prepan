package PrePAN::Web::Dispatcher;
use utf8;
use strict;
use warnings;

use PrePAN::Util;
use PrePAN::Model;
use PrePAN::Config;
use PrePAN::Util;

use Amon2::Web::Dispatcher::Lite;

get '/' => sub {
    my ($c) = @_;
    $c->render('index');
};

get '/me' => sub {
    my ($c) = @_;
    $c->redirect($c->user ? user->path : '/');
};

get '/feed' => sub {
    my ($c) = @_;
    my $res = $c->render('feed');
       $res->content_type('application/rss+xml;charset=utf8');
       $res;
};

get '/info' => sub {
    my ($c) = @_;
    $c->render('info');
};

get '/ise' => sub {
    die 'ISE';
};

# api
get '/api/me' => sub {
    my ($c) = @_;
    $c->res_json(
        $c->user ? +{
            status => 'ok',
            user   => $c->user->as_serializable(
                with_notifications => 1,
                unread_from        => $c->req->param('unread_from') || 0,
            ),
        } : +{ status => ok => user => undef }
    );
};

any '/api/notifications' => sub {
    my ($c) = @_;

    $c->user && $c->user->update({
        unread_count => 0,
        unread_from  => now,
    });

    $c->render('notifications');
};

post '/api/review.delete' => sub {
    my ($c) = @_;
    return $c->res_403 if !$c->check_user;

    my $app = $c->app->load(
        module => +{ review_id => $c->req->param('review_id') },
    );
    $app->delete_review;

    $c->res_json({ status => 'ok' });
};

get '/api/module.vote' => sub {
    my ($c) = @_;

    if ($c->module) {
        my @users = map { $_->user } @{$c->module->votes || []};
        my $already_voted = grep { $c->user && $_->id == $c->user->id } @users;

        $c->res_json({
            status         => 'ok',
            users          => [map { $_->as_serializable } @users],
            already_voted  => $already_voted,
            login_required => !$c->user,
        });
    }
    else {
        $c->res_json({
            status  => 'ng',
            message => 'Module not found',
        });
    }
};

post '/api/module.vote' => sub {
    my ($c) = @_;

    return $c->res_403 if !$c->check_user;
    return $c->res_404 if !$c->check_module;

    my $app = $c->app->load(
        module => { module => $c->module },
    );

    if ($app->vote) {
        $c->res_json({
            status => 'ok',
            user   => $c->user->as_serializable,
        });
    }
    else {
        $c->res_json({ status => 'ng' });
    }
};

post '/api/markdown2html' => sub {
    my ($c) = @_;

    my $markdown = $c->req->param('markdown');
    my $html     = format_markdown($markdown);

    $c->render_text($html);
};

# module
get '/module.submit' => sub {
    my ($c) = @_;
    return $c->res_403 if !$c->check_user;

    $c->render('module.edit');
};

post '/module.submit' => sub {
    my ($c) = @_;
    return $c->res_403 if !$c->check_user;

    my $app = $c->app->load(
        'module',
        +{
            map { $_ => $c->req->param($_) || '' }
                qw(name url summary synopsis description)
        }
    );

    if (my $module = $app->create) {
        $c->redirect($module->path);
    }
    else {
        $c->render('module.edit');
    }
};

get qr{^/module/([[:alnum:]]{10,})$}o => sub {
    my ($c) = @_;
    return $c->res_404 if !$c->check_module;

    $c->render('module');
};

get qr{^/module/([[:alnum:]]{10,}).edit$}o => sub {
    my ($c) = @_;
    return $c->res_403 if !$c->check_module_owner;

    $c->render('module.edit');
};

post qr{^/module/([[:alnum:]]{10,}).edit$}o => sub {
    my ($c) = @_;
    return $c->res_403 if !$c->check_module_owner;

    my $app = $c->app->load(
        'module',
        +{
            (map { $_ => $c->req->param($_) || '' }
                 qw(name url summary synopsis description status)),
            module => $c->module,
        },
    );

    if (my $module = $app->edit) {
        $c->redirect($module->path);
    }
    else {
        $c->render('module.edit');
    }
};

post qr{^/module/([[:alnum:]]{10,})/review.create$}o => sub {
    my ($c) = @_;
    return $c->res_403 if !$c->check_user;

    my $app = $c->app->load(
        'module',
        +{
            comment    => $c->req->param('comment') || '',
            anonymouse => $c->req->param('anonymouse') ? 1 : 0,
            module     => $c->module,
        },
    );

    if (my $review = $app->post_review) {
        $c->redirect($c->module->path('#'.$review->short_id));
    }
    else {
        $c->redirect($c->module->path('#review-form'));
    }
};

# user
get qr{^/user/(?:[[:alnum:]]{10,})$}o => sub {
    my ($c) = @_;
    return $c->res_404 if !$c->check_author;

    $c->render('user');
};

get qr{^/user/(?:[[:alnum:]]{10,})\.edit$}o => sub {
    my ($c) = @_;
    return $c->res_403 if !$c->check_privilege;

    $c->render('user.edit');
};

post qr{^/user/(?:[[:alnum:]]{10,})\.edit$}o => sub {
    my ($c) = @_;
    return $c->res_403 if !$c->check_privilege;

    my $app = $c->app->load(
        'user_info',
        +{ map { $_ => $c->req->param($_) || '' } qw(url pause_id bitbucket description) },
    );

    if ($app->edit) {
        $c->redirect($c->author->path);
    }
    else {
        $c->render('user.edit');
    }
};

# auth
PrePAN::Web->load_plugin('Web::Auth' => {
    module      => 'Twitter',
    on_finished => sub {
        my ($c, $access_token, $access_token_secret, $user_id, $screen_name) = @_;
        my $twitter_user_hash = {
            id          => $user_id,
            screen_name => $screen_name,
        };

        # BEFORE_DISPATCHトリガの実行順に依存してuserが入ってなかったりする
        $c->app->user($c->user) if $c->user;

        my $app = $c->app->load('auth', {
            twitter_user                => $twitter_user_hash,
            twitter_access_token        => $access_token,
            twitter_access_token_secret => $access_token_secret,
        });

        # 既に他のユーザにひもづけられている場合
        if ($app->user) {
            my $oauth = model->single(oauth => {
                external_user_id => $twitter_user_hash->{id}
            });

            if ($oauth && $oauth->user_id && $oauth->user_id != $app->user->id) {
                $c->session->set(
                    auth_failed => sprintf(q{This user has been already related to %s},
                                           $oauth->user->name)
                );

                return $c->redirect($c->config->{Auth}{Twitter}{callback_fail_path});
            }
        }

        my $oauth = $app->register_twitter_user;

        if ($app->user) {
            # oauth_idがある = githubユーザが/signupからきてる
            $app->user->register_oauth_id($c->session->get('oauth_id'))
                if $c->session->get('oauth_id');
            $c->session->set(prepan => $app->user->get_column('session_id'));

            return $c->redirect($c->session->get('backurl') || '/');
        }

        $c->session->set(oauth_id => $oauth->short_id);
        $c->redirect('/auth/signup');
    },

    on_error => sub {
        my ($c, $reason) = @_;
        $c->session->set(auth_failed => $reason);
        $c->redirect($c->config->{Auth}{Twitter}{callback_fail_path});
    }
});

PrePAN::Web->load_plugin('Web::Auth' => {
    module      => 'Github',
    on_finished => sub {
        my ($c, $access_token, $github_user_hash) = @_;

        # BEFORE_DISPATCHトリガの実行順に依存してuserが入ってなかったりする
        $c->app->user($c->user) if $c->user;

        my $app = $c->app->load('auth', {
            github_user         => {
                id          => $github_user_hash->{id},
                login       => $github_user_hash->{login},
                gravatar_id => $github_user_hash->{gravatar_id},
            },
            github_access_token => $access_token,
        });

        # 既に他のユーザにひもづけられている場合
        if ($app->user) {
            my $oauth = model->single(oauth => {
                external_user_id => $github_user_hash->{id}
            });

            if ($oauth && $oauth->user_id && $oauth->user_id != $app->user->id) {
                $c->session->set(
                    auth_failed => sprintf(q{This user has been already related to %s},
                                           $oauth->user->name)
                );

                return $c->redirect($c->config->{Auth}{Github}{callback_fail_path});
            }
        }

        my $oauth = $app->register_github_user;

        if ($app->user) {
            # oauth_idがある = twitterユーザが/signupからきてる
            $app->user->register_oauth_id($c->session->get('oauth_id'))
                if $c->session->get('oauth_id');
            $c->session->set(prepan => $app->user->get_column('session_id'));

            return $c->redirect($c->session->get('backurl') || '/');
        }

        $c->session->set(oauth_id => $oauth->short_id);
        $c->redirect('/auth/signup');

    },

    on_error => sub {
        my ($c, $reason) = @_;
        $c->session->set(auth_failed => $reason);
        $c->redirect($c->config->{Auth}{Github}{callback_fail_path});
    },
});

get '/auth/twitter/failed' => sub {
    my ($c) = @_;
    my $reason = $c->session->get('auth_failed');

    $c->session->expire;
    $c->render(auth_failed => +{ reason => $reason });
};

get '/auth/github/failed' => sub {
    my ($c) = @_;
    my $reason = $c->session->get('auth_failed');

    $c->session->expire;
    $c->render(auth_failed => +{ reason => $reason });
};

get '/auth/signup' => sub {
    my ($c) = @_;
    return $c->res_404 if !$c->check_oauth;

    $c->render(signup => +{ oauth => $c->oauth });
};

post '/auth/signup' => sub {
    my ($c) = @_;
    return $c->res_404 if !$c->check_oauth;

    my $app = $c->app->load(
        'user_info',
        +{
            oauth => $c->oauth,
            map { $_ => $c->req->param($_)  || '' } qw(url pause_id bitbucket description)
        },
    );

    if (my $user = $app->register) {
        $c->session->set(prepan => $user->get_column('session_id'));

        return $c->redirect($user->path);
    }

    $c->render(signup => +{ oauth => $c->oauth });
};

get '/auth/logout' => sub {
    my ($c) = @_;

    $c->session->expire;
    $c->redirect('/');
};

!!1;
