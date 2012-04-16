use inc::Module::Install;

name     'PrePAN';
author   'Kentaro Kuribayashi, <kentarok@cpan.org>';
all_from 'lib/PrePAN.pm';

requires 'Module::Install';

requires 'Plack';
requires 'Plack::Middleware::Session';
requires 'Plack::Middleware::ReverseProxy';
requires 'Plack::Handler::Starman';

requires 'Amon2';
requires 'Amon2::Auth';

requires 'Teng' => '0.14';
requires 'FormValidator::Lite';

requires 'RedisDB';

requires 'DateTime';
requires 'DateTime::Format::MySQL';

requires 'Tiffany';
requires 'Template';
requires 'Template::Plugin::FillInForm';
requires 'Template::Provider::Encoding';

requires 'parent';
requires 'Mouse';
requires 'JSON';
requires 'YAML';
requires 'Digest::SHA1';
requires 'Config::ENV' => '0.10';
requires 'Class::Load';
requires 'Path::Class';
requires 'Text::Markdown';
requires 'HTML::Trim';
requires 'Encode::Base58::BigInt';
requires 'Hash::Compact' => '0.05';

requires 'Net::Twitter::Lite';

requires 'LWP';
requires 'LWP::Protocol::https';
requires 'Mozilla::CA';

requires 'Qudo';
requires 'Qudo::Parallel::Manager';

test_requires 'Project::Libs';
test_requires 'Test::mysqld';
test_requires 'Class::Accessor::Lite';

WriteAll;
