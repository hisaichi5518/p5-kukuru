package Kukuru::Renderer::Template;
use strict;
use warnings;

sub handler {
    my ($tx, $c, %vars) = @_;
    my $charset      = $tx->req->encoding->mime_name;
    my $template     = $vars{template};
    my $status       = $vars{status} || 200;
    my $format       = $vars{format} || 'html';
    my $content_type = $vars{type};
    my $engine       = $tx->app->renderer->engines->{template} or die "Can't find tempalte engine.";
    my $output       = $engine->render($template, {c => $c, %vars});

    if (!$content_type) {
        $content_type = Kukuru::Util::find_content_type(
            format  => $format,
            charset => $charset,
        )
    }

    $tx->app->emit_hook('html_filter', $tx, \$output);

    $output = $tx->req->encoding->encode($output);
    my $headers = [
        @{$tx->app->default_headers},
        "Content-Type"   => $content_type,
        "Content-Length" => length($output),
    ];

    $tx->req->new_response($status, $headers, [$output]);
}

1;
