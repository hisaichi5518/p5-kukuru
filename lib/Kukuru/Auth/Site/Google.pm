package Kukuru::Auth::Site::Google;
use Mouse;
extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    default => "google",
);

has '+site_authorize_uri' => (
    default => "https://accounts.google.com/o/oauth2/auth",
);

has '+site_access_token_uri' => (
    default => "https://accounts.google.com/o/oauth2/token",
);

has '+scope' => (
    required => 1,
);

no Mouse;

1;
