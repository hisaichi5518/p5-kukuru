use strict;
use warnings;
use utf8;
use Test::More;
use Hash::MultiValue;
use Kukuru::Request;
use Kukuru::Transaction;

{
    package MyApp::Controller::Root;
    use Mouse;
    extends 'Kukuru::Controller';

    package MyApp;
    use Mouse;
    extends 'Kukuru';
}

sub tx {
    my $stuff = Hash::MultiValue->new(int => 1, str => "hoge", float => 0.01);
    my $req   = Kukuru::Request->new({
        'kukuru.request.body'  => $stuff,
        'kukuru.request.query' => $stuff,
    });
    Kukuru::Transaction->new(
        app   => MyApp->new(),
        req   => $req,
        match => {},
    );
}

subtest 'int' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    my $val = $c->num_param('int');
    is $val, 1;
};

subtest 'num' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    my $val = $c->num_param('float');
    is $val, 0.01;
};

subtest 'str' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    my $val = $c->num_param('str');
    is $val, undef;
};

done_testing;
