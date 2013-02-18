use strict;
use warnings;
use Test::More;

use t::lib::Exceptions;

use Try::Lite;

subtest 'no exception' => sub {
    subtest 'scalar' => sub {
        my $ret = try {
            qw/ foo bar baz /;
        } '*' => sub {};
        is $ret, 'baz';
    };

    subtest 'array' => sub {
        my @ret = try {
            qw/ foo bar baz /;
        } '*' => sub {};
        is_deeply \@ret, [qw/ foo bar baz /];
    };
};

subtest 'exception' => sub {
    subtest 'scalar' => sub {
        my $ret = try {
            die;
        } '*' => sub {
            qw/ foo bar baz /;
        };
        is $ret, 'baz';
    };

    subtest 'array' => sub {
        my @ret = try {
            die;
        } '*' => sub {
            qw/ foo bar baz /;
        };
        is_deeply \@ret, [qw/ foo bar baz /];
    };
};

done_testing;
