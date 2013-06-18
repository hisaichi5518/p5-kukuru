package Kukuru::Test;
use strict;
use warnings;
use parent "Exporter";
use Carp;
use Plack::Test;

our @EXPORT = qw(test_app);
our $_tx;

sub test_app {
    my (%args) = @_;
    my $app      = $args{app}    or croak 'app needed';
    my $client   = $args{client} or croak 'client test code needed';
    my $impl     = $args{impl};
    my $app_name = ref $app;
    my $package  = __PACKAGE__;

    local $_tx;
    if (!$app->{$package}{added_hook_for_test}) {
        unshift @{$app->event_emitter->events->{after_build_tx} ||= []}, sub {
            $_tx = $_[1];
        };

        $app->{$package}{added_hook_for_test}++;
    }

    $args{client} = sub {
        my $callback = shift;
        my $cb = sub {
            my $req = shift;
            my $res = $callback->($req);

            return ($res, $_tx);
        };

        $client->($cb)
    };

    local $Plack::Test::Impl = $impl if $impl;
    test_psgi(
        %args,
        app => $app->to_psgi,
    );
}

1;
