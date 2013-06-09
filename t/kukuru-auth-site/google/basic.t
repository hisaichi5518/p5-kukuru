use strict;
use warnings;
use Test::More;
use Kukuru::Auth::Site::Google;

subtest 'new' => sub {
    my $site = Kukuru::Auth::Site::Google->new(
        client_id     => "aaaaaaa",
        client_secret => "aaaaaaa",
        scope => "bbbb",
    );

    is $site->moniker, "google";
    is $site->site_authorize_uri, "https://accounts.google.com/o/oauth2/auth";
    is $site->site_access_token_uri, "https://accounts.google.com/o/oauth2/token";

};

done_testing;
