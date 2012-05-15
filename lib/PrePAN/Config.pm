package PrePAN::Config;
use strict;
use warnings;

use PrePAN::Util;
use Config::ENV PREPAN_ENV => default => 'local';

common {
    title => 'PrePAN',
};

config production  => {
    eval { load root->file('../../shared/production.pl')->stringify }
};

config devel => {
    eval { load root->file('../../shared/devel.pl')->stringify }
};
config local => {
    eval { load root->file('local/development.pl')->stringify       }
};
config test        => { parent 'development' };

!!1;
