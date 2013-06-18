use strict;
use warnings;
use utf8;
use Test::More;
use Hash::MultiValue;
use Kukuru::Request;
use Encode;

subtest 'decode params: default' => sub {
    my $req = Kukuru::Request->new({});

    my $stuff  = Hash::MultiValue->new("foo" => encode_utf8 "あいうえお");
    my $params = $req->_decode_parameters($stuff);

    isa_ok $params, 'Hash::MultiValue';
    is $params->{foo},'あいうえお';
};

subtest 'decode params: shift_jis' => sub {
    my $req = Kukuru::Request->new({
        'kukuru.request.encoding_name' => 'Shift_JIS'
    });

    my $stuff  = Hash::MultiValue->new("foo" => encode('Shift_JIS', "あいうえお"));
    my $params = $req->_decode_parameters($stuff);

    isa_ok $params, 'Hash::MultiValue';
    is encode('Shift_JIS', $params->{foo}), encode('Shift_JIS', 'あいうえお');
};

subtest 'body_parameters_raw' => sub {
    my $stuff = Hash::MultiValue->new(foo => encode_utf8 'あいうえお');
    my $req   = Kukuru::Request->new({'plack.request.body' => $stuff});

    my $params = $req->body_parameters_raw;
    is $params->{foo}, encode_utf8 'あいうえお';
};

subtest 'body_parameters' => sub {
    my $stuff = Hash::MultiValue->new(foo => encode_utf8 'あいうえお');
    my $req   = Kukuru::Request->new({'plack.request.body' => $stuff});

    ok !$req->env->{'kukuru.request.body'};
    my $params = $req->body_parameters;
    ok $req->env->{'kukuru.request.body'};

    is $params->{foo}, 'あいうえお';
    is_deeply $params, $req->env->{'kukuru.request.body'};
};

subtest 'encoding: default' => sub {
    my $req = Kukuru::Request->new({});
    isa_ok $req->encoding, "Encode::utf8";
};

subtest 'encoding: shift_jis' => sub {
    my $req = Kukuru::Request->new({'kukuru.request.encoding_name' => 'shift_jis'});
    isa_ok $req->encoding, "Encode::XS";
};

subtest 'encoding: hisaichi5518' => sub {
    my $req = Kukuru::Request->new({'kukuru.request.encoding_name' => 'hisaichi5518'});
    eval { $req->encoding };
    like $@, qr/encoding 'hisaichi5518' not found/;
};

subtest 'encoding_name: default' => sub {
    my $req = Kukuru::Request->new({});
    is $req->encoding_name, "utf-8";
};

subtest 'encoding_name: shift_jis' => sub {
    my $req = Kukuru::Request->new({'kukuru.request.encoding_name' => 'shift_jis'});
    is $req->encoding_name, "shift_jis";
};

subtest 'new_response: default' => sub {
    my $req = Kukuru::Request->new({});
    isa_ok $req->new_response, "Kukuru::Response";
};

subtest 'parameters' => sub {
    my $stuff = Hash::MultiValue->new(foo => 'あいうえお');
    my $req   = Kukuru::Request->new({
        'kukuru.request.body'  => $stuff,
        'kukuru.request.query' => $stuff,
    });

    my $params = $req->parameters;
    my @foo = $params->get_all('foo');

    is scalar(@foo), 2;
    is $foo[0], 'あいうえお';
};

subtest 'parameters_raw' => sub {
    my $stuff = Hash::MultiValue->new(foo => encode_utf8 'あいうえお');
    my $req   = Kukuru::Request->new({
        'plack.request.body'  => $stuff,
        'plack.request.query' => $stuff,
    });

    my $params = $req->parameters_raw;
    my @foo = $params->get_all('foo');

    is scalar(@foo), 2;
    is $foo[0], encode_utf8 'あいうえお';
};

subtest 'query_parameters' => sub {
    my $stuff = Hash::MultiValue->new(foo => encode_utf8 'あいうえお');
    my $req   = Kukuru::Request->new({'plack.request.query' => $stuff});

    ok !$req->env->{'kukuru.request.query'};
    my $params = $req->query_parameters;
    ok $req->env->{'kukuru.request.query'};

    is $params->{foo}, 'あいうえお';
    is_deeply $params, $req->env->{'kukuru.request.query'};
};

subtest 'query_parameters_raw' => sub {
    my $stuff = Hash::MultiValue->new(foo => encode_utf8 'あいうえお');
    my $req   = Kukuru::Request->new({'plack.request.query' => $stuff});

    my $params = $req->query_parameters_raw;
    is $params->{foo}, encode_utf8 'あいうえお';
};

subtest 'session' => sub {
    my $req = Kukuru::Request->new({
        'psgix.session' => {},
        'psgix.session.options' => {},
    });

    isa_ok $req->session, 'Plack::Session';
};

done_testing;
