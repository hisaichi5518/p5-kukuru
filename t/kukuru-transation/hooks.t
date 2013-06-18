use strict;
use warnings;
use Test::More;
use Kukuru::Request;
use Kukuru::Transaction;

{
    package MyApp;
    use Mouse;
    extends 'Kukuru';

    sub startup {
        my ($self) = @_;
        $self->event_emitter->on(after_build_tx => sub {
            my ($emitter, $tx) = @_;
            $tx->app->{after_build_tx}++;
            $tx->{after_build_tx}++;
        });

        $self->event_emitter->on(before_dispatch => sub {
            my ($emitter, $tx) = @_;
            $tx->app->{before_dispatch}++;
            $tx->{before_dispatch}++;
        });

        $self->event_emitter->on(after_dispatch => sub {
            my ($emitter, $tx, $res) = @_;
            $tx->app->{after_dispatch}++;
            $tx->{after_dispatch}++;
        });
    }

    package MyApp::Controller::Root;
    use Mouse;
    extends 'Kukuru::Controller';
}

my $app = MyApp->new;
sub tx {
    my $req = Kukuru::Request->new({});

    Kukuru::Transaction->new(
        app   => $app,
        req   => $req,
        match => undef,
    );
}

subtest 'after_build_tx' => sub {
    is $app->{after_build_tx}, undef;
    my $tx = tx();
    is $app->{after_build_tx}, 1;
    is $tx->{after_build_tx}, 1;
};

subtest 'before_dispatch, after_dispatch' => sub {
    my $tx = tx();
    $tx->dispatch();

    is $app->{before_dispatch}, 1;
    is $tx->{before_dispatch}, 1;
    is $app->{after_dispatch}, 1;
    is $tx->{after_dispatch}, 1;
};

done_testing;
