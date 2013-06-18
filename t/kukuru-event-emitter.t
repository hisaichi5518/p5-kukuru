use strict;
use warnings;
use Test::More;
use_ok "Kukuru::EventEmitter";

subtest "events" => sub {
    my $e = Kukuru::EventEmitter->new;
    isa_ok $e->events, "HASH";
};

subtest "on" => sub {
    my $e = Kukuru::EventEmitter->new;
    is @{$e->events->{test} || []}, 0;

    $e->on("test" => sub { });

    is scalar @{$e->events->{test}}, 1;
};

subtest "emit" => sub {
    my $e = Kukuru::EventEmitter->new;
    my $args;
    $e->on("test" => sub { $args = \@_  });
    $e->emit("test", qw(1 2 3 4 5));

    is_deeply $args, [$e, qw(1 2 3 4 5)];
};

subtest "has_subscribers" => sub {
    my $e = Kukuru::EventEmitter->new;

    is $e->has_subscribers("test"), 0;

    $e->on("test" => sub { });

    is $e->has_subscribers("test"), 1;
};

subtest "subscribers" => sub {
    my $e = Kukuru::EventEmitter->new;

    is_deeply $e->subscribers("test"), [];

    $e->on("test" => sub { });

    is scalar @{$e->subscribers("test")}, 1;
};

subtest "unsubscribe" => sub {
    my $e = Kukuru::EventEmitter->new;

    $e->unsubscribe("test");

    $e->on("test" => sub { });

    is $e->has_subscribers("test"), 1;
    $e->unsubscribe("test");
    is $e->has_subscribers("test"), 0;
};

done_testing;
