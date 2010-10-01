#!/usr/bin/env perl

use strict;
use utf8;
use warnings;

use FindBin qw($Bin);

chdir("$Bin/..");

foreach my $dest (glob("lib/Lemon/I18N/*.po")) {
    system("xgettext.pl", "-D", ".", "-o", $dest);
}

=head1 NAME

lemon_build_po.pl - Lemon i18n library builder

=head1 SYNOPSIS

lemon_build_po.pl

=head1 DESCRIPTION

Builds the i18n string catalogs for the Lemon picture gallery system.

Requires xgettext.pl

=head1 AUTHORS

Luke Ross

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
