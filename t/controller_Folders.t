use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Lemon' }
BEGIN { use_ok 'Lemon::Controller::Folders' }

ok( request('/folders/view')->is_success, 'Request should succeed' );


