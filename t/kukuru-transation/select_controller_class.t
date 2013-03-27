use strict;
use warnings;
use Test::More;
use Kukuru::Request;
use Kukuru::Transaction;

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
    }
}

sub tx {
    my $req = Kukuru::Request->new({});

    Kukuru::Transaction->new(
        app   => MyApp->new,
        req   => $req,
        match => {},
    );
}

subtest 'select_controller_class' => sub {
    my $tx = tx();

    is $tx->select_controller_class(), 'Kukuru::Controller';
};

subtest 'HashRef' => sub {
    my $tx = tx();
    my $klass = $tx->select_controller_class({controller => 'Root', action => 'index'});

    is $klass, 'MyApp::Controller::Root';
};

done_testing;
