package Lemon::Schema::Result::Folder;

use strict;
use utf8;
use warnings;

use parent 'DBIx::Class';

=head1 NAME

Lemon::Schema::Result::Folder - An folder in the Lemon picture gallery
system.

=head1 DESCRIPTION

A DBIx::Class-based class to model a folder stored in a database. A
folder can contain sub-folders and
L<DBIx::Schema::Result::Image>s. Each folder has a L<short_name> which
is used to form the folder's URI, title, description and potentially
some custom CSS for display.

Each folder may have a L<parent> folder ID - top-level folders have
this set to undefined.

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("lemon_folders");

=head1 ACCESSORS

=head2 id

Non-null integer used to identify the folder as the primary key.

=head2 parent

Integer used as a foreign key to this class to identify which folder
this row is a sub-folder of. Set to undef on top-level folders.

=head2 owner

Non-null integer used as a foreign key to L<Lemon::Schema::User> to
identify which user owns this folder.

=head2 short_name

A short name for the folder that is used to build the folder's URI -
as such it should only contain URI-safe characters.

=head2 title

Text string of up to 255 characters providing a human-readable
title of the folder.

=head2 description_mime_type

Text string of up to 255 characters specifying the MIME type of the
data stored in the L<description> field - typically "text/plain" or
"text/html".

=head2 created

The date and time the folder was added to the database.

=cut

__PACKAGE__->add_columns(
    id => {
        data_type         => "INT",
        default_value     => undef,
        is_nullable       => 0,
        is_auto_increment => 1,
        size              => 10
    },

    parent => {
        data_type     => "INT",
        default_value => undef,
        is_nullable   => 1,
        size          => 10
    },

    owner => {
        data_type     => "INT",
        default_value => undef,
        is_nullable   => 0,
        size          => 10
    },

    short_name => {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 255,
    },

    title => {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 255,
    },

    description_mime_type => {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 255,
    },

    description => {
        data_type     => "TEXT",
        default_value => undef,
        is_nullable   => 0,
        size          => 65535,
    },

    created => {
        data_type     => "DATETIME",
        default_value => undef,
        is_nullable   => 0,
        size          => 19,
    },

    custom_css => {
        data_type => "TEXT",
        default_value => undef,
        is_nullable => 1,
        size => 65535,
    }
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 parent/subfolders

This class may have L<subfolders> or itself be a subfolder of
L<parent>.

=head2 owner

This class belongs to L<Lemon::Schema::Result::User> using L<owner>.

=head2 images

This class may contain L<Lemon::Schema::Result::Image>s.

=cut

__PACKAGE__->belongs_to("parent", "Lemon::Schema::Result::Folder", { id => "parent" });
__PACKAGE__->has_many(
    "subfolders",
    "Lemon::Schema::Result::Folder",
    { "foreign.parent" => "self.id" },
);
__PACKAGE__->belongs_to("owner", "Lemon::Schema::Result::User", { id => "owner" });
__PACKAGE__->has_many(
    "images",
    "Lemon::Schema::Result::Image",
    { "foreign.folder" => "self.id" },
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
