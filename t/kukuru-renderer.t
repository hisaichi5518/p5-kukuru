use strict;
use warnings;
use Test::More;
use Kukuru::Renderer;

subtest 'BUILD' => sub {
    my $renderer = Kukuru::Renderer->new;

    my @handlers = qw(template text json data);
    isa_ok $renderer->handlers->{$_}, 'CODE', $_ for @handlers;
};

subtest 'add_handler' => sub {
    my $renderer = Kukuru::Renderer->new;
    ok !$renderer->handlers->{test};
    $renderer->add_handler('test' => sub {});

    isa_ok $renderer->handlers, 'HASH';
    isa_ok $renderer->handlers->{test}, 'CODE';
};

subtest 'handlers' => sub {
    my $renderer = Kukuru::Renderer->new;
    isa_ok $renderer->handlers, 'HASH';
};

subtest 'render with template' => sub {
    my $renderer = Kukuru::Renderer->new;

    my $count = 0;
    $renderer->add_handler(template => sub {
        my ($tx, $c, %vars) = @_;

        $count++;
        is $vars{handler},  'template';
        is $vars{template}, 'root/index';
    });

    my $tx = 'dummy';
    my $c  = 'dummy';
    is $count, 0;
    $renderer->render($tx, $c, template => 'root/index');
    is $count, 1;
};


subtest 'render with text' => sub {
    my $renderer = Kukuru::Renderer->new;

    my $count = 0;
    $renderer->add_handler(template => sub {});
    $renderer->add_handler(text => sub {
        my ($tx, $c, %vars) = @_;

        $count++;
        is $vars{handler},  'text';
        is $vars{text},     'hoge';
        is $vars{template}, 'root/index';
    });

    my $tx = 'dummy';
    my $c  = 'dummy';
    is $count, 0;
    $renderer->render($tx, $c, text => "hoge", template => 'root/index');
    is $count, 1;
};


subtest 'render with hander' => sub {
    my $renderer = Kukuru::Renderer->new;

    my $count = 0;
    $renderer->add_handler(test => sub {
        my ($tx, $c, %vars) = @_;

        $count++;
    });

    my $tx = 'dummy';
    my $c  = 'dummy';
    is $count, 0;
    $renderer->render($tx, $c, handler => 'test');
    is $count, 1;
};

subtest 'render without handler' => sub {
    my $renderer = Kukuru::Renderer->new;

    my $tx = 'dummy';
    my $c  = 'dummy';
    eval { $renderer->render($tx, $c, handler => 'hisaichi5518') };
    like $@, qr/No handler for "hisaichi5518" available/;
};

done_testing;
