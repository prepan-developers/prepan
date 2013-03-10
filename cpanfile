requires 'Plack';
requires 'Plack::Middleware::Session';
requires 'Plack::Middleware::ReverseProxy';
requires 'Plack::Handler::Starman';

requires 'Amon2';
requires 'Amon2::Auth';

requires 'DBD::mysql';
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
requires 'JSON::XS';
requires 'YAML';
requires 'Digest::SHA1';
requires 'Encode::Base58::BigInt';
requires 'Config::ENV' => '0.10';
requires 'Class::Load';
requires 'Path::Class';
requires 'Text::Markdown';
requires 'HTML::Trim';
requires 'Hash::Compact' => '0.05';

requires 'Net::OAuth';
requires 'Net::Twitter::Lite';

requires 'LWP';
requires 'LWP::Protocol::https';
requires 'Mozilla::CA';

requires 'Qudo';
requires 'Qudo::Parallel::Manager';

on develop => sub {
    recommends 'git://github.com/kentaro/cinnamon.git';
};

on test => sub {
    requires 'Module::Install';
    requires 'Project::Libs';
    requires 'Test::mysqld';
    requires 'Class::Accessor::Lite';
};
