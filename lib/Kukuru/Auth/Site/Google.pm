package Kukuru::Auth::Site::Google;
use Mouse;
extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    is => 'rw',
    default => "google",
);

has '+site_authorize_uri' => (
    is => 'rw',
    default => "https://accounts.google.com/o/oauth2/auth",
);

has '+site_access_token_uri' => (
    is => 'rw',
    default => "https://accounts.google.com/o/oauth2/token",
);

has '+scope' => (
    is => 'rw',
    required => 1,
);

1;
