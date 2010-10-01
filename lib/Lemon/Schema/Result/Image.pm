package Lemon::Schema::Result::Image;

use strict;
use utf8;
use warnings;

use parent 'DBIx::Class';

=head1 NAME

Lemon::Schema::Result::Image - An image stored in a database in the
Lemon picture gallery system.

=head1 DESCRIPTION

A DBIx::Class-based class to model a logged an image. Images are
associated with the folder they are in. The image also stores
the image data, the image's MIME type and a title.

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("lemon_images");

=head1 ACCESSORS

=head2 id

Non-null integer used to identify the image as the primary key.

=head2 folder

Non-null integer used as a foreign key to Lemon::Schema::Folder
to identify which folder the image is stored in.

=head2 mime_type

Text string of up to 255 characters identifying the MIME type of
the data in the L<content> column.

=head2 content

Binary blob of up to 2**32 bytes (database dependent) of the raw image
data as uploaded.

=head2 title

Text string of up to 255 characters providing a human-readable
description of the image.

=head2 created

The date and time the image was added to the database.

=cut

__PACKAGE__->add_columns(
    id => {
        data_type         => "INT",
        default_value     => undef,
        is_nullable       => 0,
        is_auto_increment => 1,
        size              => 10
    },

    folder => {
        data_type     => "INT",
        default_value => undef,
        is_nullable   => 0,
        size          => 10
    },

    mime_type => {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 255,
    },

    content => {
        data_type     => "LONGBLOB",
        default_value => undef,
        is_nullable   => 0,
        size          => 2 ** 32 - 1,
    },

    title => {
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
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 folder

This class belongs to L<Lemon::Schema::Result::Folder> using L<folder>.

=cut

__PACKAGE__->belongs_to("folder", "Lemon::Schema::Result::Folder", { id => "folder" });

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
