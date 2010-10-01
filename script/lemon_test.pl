#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Catalyst::Test 'Lemon';

my $help = 0;

GetOptions('help|?' => \$help);

pod2usage(1) if ($help || !$ARGV[0]);

print request($ARGV[0])->content . "\n";

1;

=head1 NAME

lemon_test.pl - Lemon test

=head1 SYNOPSIS

lemon_test.pl [options] uri

 Options:
   -help    display this help and exits

 Examples:
   lemon_test.pl http://localhost/some_action
   lemon_test.pl /some_action

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst action in the Lemon picture gallery system from the
command line.

=head1 AUTHORS

Luke Ross

Catalyst Contributors, see Catalyst.pm

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
