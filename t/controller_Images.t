use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Lemon' }
BEGIN { use_ok 'Lemon::Controller::Images' }

ok( request('/images')->is_success, 'Request should succeed' );


