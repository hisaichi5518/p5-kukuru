use strict;
use warnings;
use Test::More;

{
    package MyApp;
    use Mouse;
    extends 'Kukuru';

    package MyApp::Deep::Deep::DeepDeep::Deep;
    use Mouse;
    extends 'Kukuru';
}

subtest 'add hook' => sub {
    my $app = MyApp->new;

    is scalar(@{$app->hooks->{hook} || []}), 0;

    $app->add_hook(hook => sub {});

    is scalar(@{$app->hooks->{hook} || []}), 1;

    $app->add_hook(hook => sub {});

    is scalar(@{$app->hooks->{hook} || []}), 2;
};

subtest 'app_controller_class' => sub {
    my $class = "MyApp";
    my $app   = $class->new;

    is $app->app_controller_class, "$class\::Controller";
};

subtest 'app_controller_class' => sub {
    my $class = "MyApp::Deep::Deep::DeepDeep::Deep";
    my $app   = $class->new;

    is $app->app_controller_class, "$class\::Controller";
};

subtest 'default controller class' => sub {
   is +Kukuru->controller_class, 'Kukuru::Controller';
};

subtest 'default_headers' => sub {
    my $app = MyApp->new;
    my $headers = $app->default_headers;
    my $h = Plack::Util::headers($headers);

    is $h->get("X-XSS-Protection"), "1; mode=block";
    is $h->get("X-Frame-Options"), "SAMEORIGIN";
    is $h->get("X-Content-Type-Options"), "nosniff";
};

subtest 'emit hook' => sub {
    my $app = MyApp->new;
    my $count;
    $app->add_hook(test => sub {$count++});
    $app->add_hook(test => sub {$count++});

    $app->emit_hook('test');
    is $count, 2;

    $app->emit_hook('test');
    is $count, 4;
};

subtest 'emit hook with args' => sub {
    my $app = MyApp->new;
    my $count;
    $app->add_hook(test => sub {
        my ($app, @args) = @_;
        $count = $args[0];
    });

    $app->emit_hook('test', 1);
    is $count, 1;

    $app->emit_hook('test', 2);
    is $count, 2;
};

subtest 'exception_class' => sub {
    is +Kukuru->exception_class, "Kukuru::Exception";
};

subtest 'default request class' => sub {
   is +Kukuru->request_class, 'Kukuru::Request';
};

done_testing;
