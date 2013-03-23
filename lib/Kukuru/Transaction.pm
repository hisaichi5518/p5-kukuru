package Kukuru::Transaction;
use Mouse;
use Scalar::Util;

has [qw/app req/] => (
    is => 'rw',
    required => 1,
);

has match => (
    is => 'rw',
    default => sub { +{} },
);

has _controllers => (
    is =>  'rw',
    default => sub { +[] },
);

no Mouse;

sub BUILD {
    my ($self) = @_;
    $self->app->emit_hook("after_build_tx", $self);
}

sub dispatch {
    my ($self) = @_;
    my $match = $self->match;

    $self->app->emit_hook("before_dispatch", $self);
    my $res = eval { $self->_dispatch($match) };
    if ($@) {
        if ((ref $@ || '') eq $self->app->exception_class) {
            my $c = $self->_last_controller_object;
            $res = $c->render(
                exception => $@->message,
                status    => $@->status,
            );
        }
        else {
            die $@;
        }
    }
    elsif (!$res) {
        die "Can't found response object in action.";
    }
    $self->app->emit_hook("after_dispatch", $self, $res);

    $res;
}

sub _dispatch {
    my ($self, $match) = @_;
    my $action = $match->{action};

    if ((ref $action || '') eq 'ARRAY') {
        # 配列の場合は、Controllerぶん回す。
        for my $dest (@$action) {
            my $res = $self->_dispatch($dest);
            return $res if $res;
        }
    }
    else {
        my $klass = $self->select_controller_class($match);
        my $c = $klass->new(
            app  => $self->app,
            tx   => $self,
            args => $match, # 名前考える
        );

        Scalar::Util::weaken($c->{tx});

        push @{$self->_controllers}, $c;
        $c->dispatch($match);
    }
}

sub _last_controller_object {
    my ($self) = @_;
    $self->_controllers->[scalar(@{$self->_controllers}) - 1];
}

sub select_controller_class {
    my ($self, $match) = @_;

    if ($match && $match->{controller}) {
        Kukuru::Util::load_class(
            $match->{controller}, $self->app->app_controller_class
        );
    }
    else {
        $self->app->app_controller_class;
    }
}

__PACKAGE__->meta->make_immutable;
