package Kukuru::Plugin::Auth::Site;
use strict;
use warnings;

sub init {
    my ($class, $app, $options) = @_;

    for my $name (keys $options) {
        my $conf    = $options->{$name};
        my $klass   = Kukuru::Util::load_class($name, "Kukuru::Auth::Site");
        my $site    = $klass->new($conf);
        my $moniker = $site->moniker;

        my $auth_path     = "/auth/$moniker/authenticate";
        my $callback_path = "/auth/$moniker/callback";

        my $on_finished = $conf->{on_finished} or die "Can't find 'on_finished' callback";
        my $on_error    = $conf->{on_error} || sub {
            my ($c, $err) = @_;
            $c->app->exception_class->throw(
                status  => 403,
                message => "Authentication error in $klass: $err",
            );
        };

        $app->router->get($auth_path => sub {
            my $c = shift;
            my $auth_uri = $site->auth_uri($c,
                callback => $c->uri_for($callback_path),
            );

            $c->redirect($auth_uri);
        });

        $app->router->get($callback_path => sub {
            my $c = shift;

            $site->callback($c,
                on_finished => sub { $on_finished->($c, @_) },
                on_error    => sub { $on_error->($c, @_)    },
            );
        });
    }
}

1;
__END__

sub startup {
    my ($self) = @_;

    $self->load_plugin(
        OAuth => {
            Twitter => {
                consumer_key    => "",
                consumer_secret => "",
                on_finished => sub {},
            },
            Zaim => {
                consumer_key    => "",
                consumer_secret => "",
                on_finished => sub {},
            },
            Github => {
                consumer_key    => "",
                consumer_secret => "",
                on_finished => sub {},
            },
        },
    );
}

=cut
