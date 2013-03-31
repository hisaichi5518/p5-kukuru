use strict;
use warnings;
use Test::More;

{
    package MyApp::Controller::Root;
    use Mouse;
    extends 'Kukuru::Controller';

    package MyApp;
    use Mouse;
    extends 'Kukuru';
}

sub tx {
    my $req = Kukuru::Request->new({
        HTTP_HOST => 'localhost',
    });

    Kukuru::Transaction->new(
        app   => MyApp->new(),
        req   => $req,
        match => {},
    );
}

subtest 'with path' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    my $res = $c->redirect('/');

    is $res->location, 'http://localhost/';
};

subtest 'with ArrayRef' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    my $res = $c->redirect([test => 1]);

    is $res->location, 'http://localhost/?test=1';
};

subtest 'with http://localhost/' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    my $res = $c->redirect("http://localhost/");

    is $res->location, 'http://localhost/';
};

subtest 'with status' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    my $res = $c->redirect('/', 301);

    is $res->code, 301;
};

done_testing;
