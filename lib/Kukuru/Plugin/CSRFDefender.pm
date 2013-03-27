package Kukuru::Plugin::CSRFDefender;
use strict;
use warnings;

sub init {
    my ($class, $app, $options) = @_;

    $app->add_hook('before_dispatch' => sub {
        my ($app, $tx) = @_;

        my $req = $tx->req;
        if ($class->_is_need_validated($req->method)) {
            my $param_token   = $req->param("__csrf_token");
            my $session_token = $req->session->get("__csrf_token");

            if (!$param_token || !$session_token || ($param_token ne $session_token)) {
                return $app->exception_class->throw(
                    status  => 403,
                    message => "error: csrf token",
                );
            }
        }

        return;

    });

    $app->add_hook('html_filter' => sub {
        my ($app, $tx, $output) = @_;

        $$output =~ s|
            (<form\s*[^>]*method="POST"[^>]*>)
        |
            qq!$1\n<input type="hidden" name="__csrf_token" value="@{[$class->csrf_token($tx)]}" />!
        |igxe;
    });
}

sub csrf_token {
    my ($class, $tx) = @_;

    my $token;
    my @chars = ('a'..'z', 'A'..'Z', 0..9);
    for (0..31) {
        $token .= $chars[int rand @chars];
    }

    $tx->req->session->set(
        '__csrf_token' => $token
    );
}

sub _is_need_validated {
    my ($class, $method) = @_;
    return 0 if !$method;
    $method = uc $method;

    return
        $method eq 'POST'    ? 1 :
        $method eq 'PATCH'   ? 1 :
        $method eq 'PUT'     ? 1 :
        $method eq 'DELETE'  ? 1 : 0;
}

1;
