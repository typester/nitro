package Nitro::Types;
use strict;
use warnings;
use Mouse::Util::TypeConstraints;

use Nitro::Config;

coerce 'Nitro::Config'
    => from 'Str'
    => via {
        my $conf = do $_ or die 'config file load error: ', $@ || $!;
        Nitro::Config->new($conf);
    };

1;
