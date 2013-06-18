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
        $self->event_emitter->on(before_dispatch => sub {
            my ($app, $tx) = @_;

            $app->exception_class->throw(
                status  => 403,
                message => "Forbidden",
            );
        });
    }
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

subtest 'return response object at before_dispatch' => sub {
    my $tx = tx();
    my $res = $tx->dispatch();
    is_deeply $res->content, ["Forbidden"];
};

done_testing;
