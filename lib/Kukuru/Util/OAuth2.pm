package Kukuru::Util::OAuth2;
use strict;
use warnings;
use URI::Escape ();

# copied OAuth::Lite2::Util::parse_content
sub parse_content {
    my $content = shift;
    my $params  = Hash::MultiValue->new;
    for my $pair (split /\&/, $content) {
        my ($key, $value) = split /\=/, $pair;
        $key   = URI::Escape::uri_unescape($key  ||'');
        $value = URI::Escape::uri_unescape($value||'');
        $params->add($key, $value);
    }
    return $params;
}

1;
