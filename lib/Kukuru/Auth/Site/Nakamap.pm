package Kukuru::Auth::Site::Nakamap;
use Mouse;

extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    default => "nakamap",
);

has '+site_authorize_uri' => (
    default => "https://nakamap.com/dialog/oauth",
);

has '+site_access_token_uri' => (
    default => "https://thanks.nakamap.com/oauth/access_token",
);

has '+use_state' => (
    default => 0,
);

no Mouse;

1;
