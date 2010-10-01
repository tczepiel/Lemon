use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Lemon' }
BEGIN { use_ok 'Lemon::Controller::Users' }

ok( request('/users/login')->is_success, 'Request should succeed' );


