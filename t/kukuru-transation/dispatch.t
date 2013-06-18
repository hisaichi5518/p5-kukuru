use strict;
use warnings;
use Test::More;
use Test::LeakTrace;

{
    package MyApp;
    use Mouse;
    extends 'Kukuru';

    package MyApp::Controller::Root;
    use Mouse;
    extends 'Kukuru::Controller';

    sub index {
        my ($self) = @_;
        $self->tx->{run_controller}++;
        $self->render(text => "ok");
    }

    sub _not_found {}

    sub exception1 {
        die "FUCK";
    }

    sub exception2 {
        my ($self) = @_;
        $self->app->exception_class->throw("FUCK2");
    }
}

sub tx {
    my $match = shift;
    my $req = Kukuru::Request->new({});

    Kukuru::Transaction->new(
        app   => MyApp->new,
        req   => $req,
        match => $match,
    );
}

subtest 'dispatch: {controller => Str, action => Str}' => sub {
    my $tx = tx({
        controller => 'Root',
        action     => 'index',
    });

    is $tx->{run_controller}, undef;
    $tx->dispatch;
    is $tx->{run_controller}, 1;
};

subtest 'not found response.' => sub {
    my $tx = tx({
        controller => 'Root',
        action     => '_not_found',
    });

    my $res = eval { $tx->dispatch };
    ok !$res;
    ok $@;
    like $@, qr/Can't found response object/;
};

subtest 'exception1' => sub {
    my $tx = tx({
        controller => 'Root',
        action     => 'exception1',
    });

    my $res = eval { $tx->dispatch };
    ok !$res;
    ok $@;
    like $@, qr/FUCK/;
};

subtest 'exception2' => sub {
    my $tx = tx({
        controller => 'Root',
        action     => 'exception2',
    });

    my $res = $tx->dispatch;
    is $res->code, 500;
};

no_leaks_ok {
    my $tx = tx({
        controller => 'Root',
        action     => 'exception2',
    });

    my $res = $tx->dispatch;
};

subtest '_controller' => sub {
    my $tx = tx({
        controller => 'Root',
        action     => 'exception2',
    });

    $tx->dispatch;
    is @{$tx->_controllers}, 1;
};

done_testing;
