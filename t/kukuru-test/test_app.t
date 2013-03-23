use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;
use Kukuru::Test;
use Test::LeakTrace;

{
    package MyApp;
    use Kukuru::Lite;

    get '/' => sub {
        my ($self) = @_;
        $self->render(text => "ok");
    };
};

test_app
    app => MyApp->app,
    client => sub {
        my $cb  = shift;
        my ($res, $tx) = $cb->(GET '/');

        isa_ok $res, "HTTP::Response";
        isa_ok $tx, "Kukuru::Transaction";
    }
;

done_testing;
