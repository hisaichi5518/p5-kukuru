use strict;
use warnings;
use Test::More;
use Kukuru::Response;

subtest 'new' => sub {
    my $res = Kukuru::Response->new(200);
    is $res->code, 200;
};

done_testing;
