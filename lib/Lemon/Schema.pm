package Lemon::Schema;

use strict;
use utf8;
use warnings;

use parent 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

sub deploy_if_required {
    my ($self) = @_;

    my $user_table_exists = $self->storage->dbh
        ->table_info('', '', 'lemon_users')->fetchrow_arrayref();

    $self->deploy() if not $user_table_exists;
}

sub administrator_configured {
    my ($self) = @_;

    return $self->resultset("User")->count();
}

=head1 NAME

Lemon::Schema - Database schema for Lemon

=head1 DESCRIPTION

Defines the database schema for the Lemon picture gallery system.

=head1 SEE ALSO

L<DBIx::Class::Schema>

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
