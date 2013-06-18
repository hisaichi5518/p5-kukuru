use strict;
use warnings;
use Test::More;
use Kukuru::Auth::Site::Instagram;

subtest 'new' => sub {
    my $site = Kukuru::Auth::Site::Instagram->new(
        client_id     => "aaaaaaa",
        client_secret => "aaaaaaa",
    );

    is $site->moniker, "instagram";
    is $site->site_authorize_uri, "https://api.instagram.com/oauth/authorize";
    is $site->site_access_token_uri, "https://api.instagram.com/oauth/access_token";

};

done_testing;
