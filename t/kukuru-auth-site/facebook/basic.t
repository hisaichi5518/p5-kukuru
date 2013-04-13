use strict;
use warnings;
use Test::More;
use Kukuru::Auth::Site::Facebook;

subtest 'new' => sub {
    my $site = Kukuru::Auth::Site::Facebook->new(
        client_id     => "aaaaaaa",
        client_secret => "aaaaaaa",
    );

    is $site->moniker, "facebook";
    is $site->site_authorize_uri, "https://www.facebook.com/dialog/oauth";
    is $site->site_access_token_uri, "https://graph.facebook.com/oauth/access_token";
};

done_testing;
