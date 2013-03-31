use strict;
use warnings;
use utf8;
use Test::More;
use Kukuru::Controller;

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
        HTTP_HOST   => 'localhost',
    });

    Kukuru::Transaction->new(
        app   => MyApp->new(),
        req   => $req,
        match => {},
    );
}

subtest 'args is String and ArrayRef' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    is $c->uri_for('/', [test => 1]), "http://localhost/?test=1";
    is $c->uri_for('/', [test => 1, test => 2]), "http://localhost/?test=1&test=2";
    is $c->uri_for('/test', [test => 1, test => 2]), "http://localhost/test?test=1&test=2";
    is $c->uri_for('/あいうえお'), "http://localhost/%E3%81%82%E3%81%84%E3%81%86%E3%81%88%E3%81%8A";
    is $c->uri_for('/', [test => 'あいうえお']), "http://localhost/?test=%E3%81%82%E3%81%84%E3%81%86%E3%81%88%E3%81%8A";
};

subtest 'error' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    eval { $c->uri_for('test') };
    like $@, qr{path must begin with /};
};

done_testing;
