#!/usr/bin/env perl

use strict;
use warnings;
use Cinnamon::DSL;

set application => 'prepan';
set repository  => 'git://github.com/prepan-developers/prepan.git';
set user        => 'deployer';

role development => [qw(local.prepan.org)], {
    deploy_to          => '/var/www/prepan',
    branch             => 'origin/master',
    service_web_dir    => '/service/web',
    service_worker_dir => '/service/worker',
};

role production => [qw(app-1.us-west-1 app-2.us-west-1)], {
    deploy_to          => '/var/www/prepan',
    branch             => 'origin/master',
    service_web_dir    => '/service/web',
    service_worker_dir => '/service/worker',
};

task deploy => {
    setup => {
        dir => sub {
            my ($host, @args) = @_;
            my $repository = get('repository');
            my $deploy_to  = get('deploy_to');
            my $branch     = get('branch');

            remote {
                run "git clone $repository $deploy_to && cd $deploy_to && git checkout -q $branch";
            } $host;
        },

        app => sub {
            my ($host, @args) = @_;
            my $deploy_to = get('deploy_to');
            my $role      = get('role');

            remote {
                for my $service (qw(web worker)) {
                    my $service_dir = get("service_${service}_dir");

                    run "ln -sf $deploy_to/bin/$role.$service.run.sh $service_dir/run";
                    run "ln -sf $deploy_to/bin/$role.$service.log.run.sh $service_dir/log/run";
                }
            } $host;
        },

        db => sub {
            my ($host, @args) = @_;
            my $deploy_to = get('deploy_to');
            remote {
                run "cd $deploy_to && ./script/setup.sh";
            } $host;
        },
    },

    config => sub {
        my ($host, @args) = @_;
        my $user      = get('user');
        my $deploy_to = get('deploy_to');

        run "scp", "local/development.pl", "$user\@$host:$deploy_to/local/development.pl";
        run "scp", "local/production.pl",  "$user\@$host:$deploy_to/local/production.pl";
    },

    update => sub {
        my ($host, @args) = @_;
        my $deploy_to = get('deploy_to');
        my $branch    = get('branch');

        remote {
            run "cd $deploy_to && git checkout . && git fetch origin && git checkout -q $branch && git submodule update --init && carton install";
        } $host;
    },
};

for my $service (qw(web worker)) {
    task $service => {
        start => sub {
            my ($host, @args) = @_;
            my $service = get("service_${service}_dir");

            remote {
                sudo "svc -u $service";
            } $host;
        },

        stop => sub {
            my ($host, @args) = @_;
            my $service = get("service_${service}_dir");

            remote {
                sudo "svc -d $service";
            } $host;
        },

        restart => sub {
            my ($host, @args) = @_;
            my $service = get("service_${service}_dir");

            remote {
                run "svc -t $service";
            } $host;
        },

        status => sub {
            my ($host, @args) = @_;
            my $service = get("service_${service}_dir");

            remote {
                sudo "svstat $service";
            } $host;
        },
    };
}
