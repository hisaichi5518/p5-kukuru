package Kukuru::Auth::Site::Nakamap;
use Mouse;

extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    is => 'rw',
    default => "nakamap",
);

has '+site_authorize_uri' => (
    is => 'rw',
    default => "https://nakamap.com/dialog/oauth",
);

has '+site_access_token_uri' => (
    is => 'rw',
    default => "https://thanks.nakamap.com/oauth/access_token",
);

has '+use_state' => (
    is => 'rw',
    default => 0,
);

no Mouse;

1;
