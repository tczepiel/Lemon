package Lemon::Model::DB;

use strict;
use utf8;
use warnings;

use parent 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Lemon::Schema'
);

=head1 NAME

Lemon::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Lemon>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> model using the schema L<Lemon::Schema>.

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
