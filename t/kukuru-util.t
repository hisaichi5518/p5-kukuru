use strict;
use warnings;
use utf8;
use Test::More;
use Kukuru::Util;

subtest 'find_content_type: dont have charset' => sub {
    is +Kukuru::Util::find_content_type(
        format => 'html',
    ), "text/html";
};

subtest 'find_content_type: have charset' => sub {
    is +Kukuru::Util::find_content_type(
        format  => 'html',
        charset => 'UTF-8',
    ), "text/html; charset=UTF-8";
};

subtest 'find_content_type: dont have format' => sub {
    eval { Kukuru::Util::find_content_type() };
    ok $@;
    like $@, qr/require format/;
};

subtest 'load class' => sub {
    my $klass = Kukuru::Util::load_class('Kukuru');
    is $klass, 'Kukuru';
};

subtest 'load class with prefix' => sub {
    my $klass = Kukuru::Util::load_class('Response', 'Kukuru');
    is $klass, 'Kukuru::Response';
};

subtest 'load class with +' => sub {
    my $klass = Kukuru::Util::load_class('+Kukuru::Request', 'Hoge');
    is $klass, 'Kukuru::Request';
};

done_testing;
