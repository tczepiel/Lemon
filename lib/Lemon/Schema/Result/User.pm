package Lemon::Schema::Result::User;

use strict;
use utf8;
use warnings;

use parent 'DBIx::Class';

=head1 NAME

Lemon::Schema::Result::User - An user in the Lemon picture gallery
system.

=head1 DESCRIPTION

A DBIx::Class-based class to model a logged in user. In Lemon,
all logged in users have administrative privileges and can
create new folders and manage them.

=head1 ACCESSORS

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("lemon_users");

=head2 id

Non-null integer used to identify the user as the primary key.

=head2 email

Text string of up to 255 characters containing the user's email
address, which is also used as a username. Must be unique.

=head2 password

Text string of up to 255 characters which is the user's login
password.

=head2 created

The date and time the user was added to the database.

=cut

__PACKAGE__->add_columns(
    id => {
        data_type         => "INT",
        default_value     => undef,
        is_nullable       => 0,
        is_auto_increment => 1,
        size              => 10
    },

    email => {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 255,
    },

    password => {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 255,
    },

    created => {
        data_type     => "DATETIME",
        default_value => undef,
        is_nullable   => 0,
        size          => 19,
    }
);

=head1 RELATIONS

=head2 folders

A user has many L<Lemon::Schema::Result::Folder>s to store their
images in.

=cut

__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("email", ["email"]);
__PACKAGE__->has_many(
    "folders",
    "Lemon::Schema::Result::Folder",
    { "foreign.owner" => "self.id" },
);

=head1 SEE ALSO

=over

=item *

L<DBIx::Class::Row>

=back

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
