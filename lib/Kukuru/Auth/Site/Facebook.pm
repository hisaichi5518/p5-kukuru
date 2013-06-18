package Kukuru::Auth::Site::Facebook;
use Mouse;

extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    default => "facebook",
);

has '+site_authorize_uri' => (
    default => "https://www.facebook.com/dialog/oauth",
);

has '+site_access_token_uri' => (
    default => "https://graph.facebook.com/oauth/access_token",
);

no Mouse;

1;
