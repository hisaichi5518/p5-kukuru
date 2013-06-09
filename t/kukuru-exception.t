use strict;
use warnings;
use utf8;
use Test::More;
use Kukuru::Exception;

subtest 'croak' => sub {
    eval { Kukuru::Exception->croak("test") }; my $line = __LINE__;

    ok my $e = $@;
    is $e->message, "test";
    is $e->file, __FILE__;
    is $e->line, $line;
};

subtest 'croakf' => sub {
    eval { Kukuru::Exception->croakf('%s', "test") }; my $line = __LINE__;

    ok my $e = $@;
    is $e->message, "test";
    is $e->file, __FILE__;
    is $e->line, $line;
};

subtest 'stringify' => sub {
    eval {
        Kukuru::Exception->throw(message => "test");
    };

    ok my $e = $@;
    is "$e", "test";
};

subtest 'stringify' => sub {
    eval {
        Kukuru::Exception->throw(
            message => "test",
            file => __FILE__,
            line => 10,
        );
    };

    my $file = __FILE__;
    ok my $e = $@;
    like "$e", qr/test at $file line 10./;
};

subtest 'throw' => sub {
    ok !$@;
    my $file = __FILE__;
    my $line = __LINE__;

    eval {
        Kukuru::Exception->throw(
            message => 'message',
            file    => $file,
            line    => $line,
        );
    };
    ok my $e = $@;
    is $e->message, 'message';
    is $e->file, $file;
    is $e->line, $line;
};

subtest 'stringify' => sub {
    my $file = __FILE__;
    my $line = __LINE__;

    eval {
        Kukuru::Exception->throw(
            message => 'message',
            file    => $file,
            line    => $line,
        );
    };
    ok my $e = $@;
    ok $e->stringify =~  m/message at (.+) line (\d+)\./;
    is $1, $file;
    is $2, $line;
};

done_testing;
