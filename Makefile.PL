use strict;
use warnings;

BEGIN {
    my @devmods = qw(
    );
    my @not_available;

    {
        $|=1;
        local *STDOUT;
        eval qq{use inc::Module::Install; 1;} or push @not_available, 'inc::Module::Install';
    }

    for my $mod (@devmods) {
        eval qq{require $mod} or push @not_available, $mod;
    }
    if (@not_available) {
        print qq{# The following modules are not available.\n};
        print qq{# `$^X $0 | cpanm` will install them:\n};
        print $_, "\n" for @not_available;
        print "\n";
        exit -1;
    }
}

use inc::Module::Install;
$Module::Install::AUTHOR = 0 if $ENV{TRAVIS};

name 'Nitro';
all_from 'lib/Nitro.pm';

test_requires 'Test::More' => '0.86';

requires 'perl' => '5.008001';
requires 'AnyEvent' => '7.02';
requires 'AnyEvent::HTTP' => '2.14';
requires 'Mouse' => '1.02';
requires 'POE' => '1.354';;
requires 'POE::Component::Server::IRC' => '1.54';
requires 'URI::Query' => '0.10';

WriteAll;
