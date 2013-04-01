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
    my $stuff = Hash::MultiValue->new(foo => '1', test => "hoge");
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

subtest 'num' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    my $val = $c->num_param('foo');
    is $val, 1;
};

subtest 'str' => sub {
    my $c = MyApp::Controller::Root->new(tx => tx());
    my $val = $c->num_param('test');
    is $val, undef;
};

done_testing;
