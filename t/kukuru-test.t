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
        $self->tx->{test}++;
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

        is $res->code, 200;
        is $tx->{test}, 1;

        is $tx->app->{'Kukuru::Test'}{added_hook_for_test}, 1;
        is scalar(@{$tx->app->hooks->{after_build_tx}}), 1;
    }
;

test_app
    app => MyApp->app,
    client => sub {
        my $cb  = shift;
        my ($res, $tx) = $cb->(GET '/');

        is $tx->{test}, 1;
        is scalar(@{$tx->app->hooks->{after_build_tx}}), 1;
    }
;

done_testing;
