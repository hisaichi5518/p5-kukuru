package Kukuru::Auth::Site::Facebook;
use Mouse;

extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    is => 'rw',
    default => "facebook",
);

has '+site_authorize_uri' => (
    is => 'rw',
    default => "https://www.facebook.com/dialog/oauth",
);

has '+site_access_token_uri' => (
    is => 'rw',
    default => "https://graph.facebook.com/oauth/access_token",
);

1;
