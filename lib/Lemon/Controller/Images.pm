package Lemon::Controller::Images;

use strict;
use utf8;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

Lemon::Controller::Images - Catalyst Controller for image handling in
the Lemon picture gallery system.

=head1 DESCRIPTION

These Catalyst actions control the creation, editing, viewing and
deletion of images in the folders.

=head1 METHODS

=cut


=head2 create

Show the user the form for uploading a new image. Takes one parameter,
$folder, which is the ID of the folder the image should be uploaded
to.

Requires a valid user to be logged in (will redirect to login page
otherwise).

=cut

sub create :Local :Args(1) {
    my ($self, $c, $folder) = @_;

    # Check user is logged in
    $c->detach("/users/login") unless $c->user;

    # Set up the template
    $c->stash(
        folder   => $folder,
        template => "images/create.tt2"
    );
    $c->forward("Lemon::View::TT");
}

=head2 delete

Deletes an image from a folder. This actually does a database delete
so the image cannot be recovered afterwards. Takes one parameter, C<$id>, the
integer ID of the image in the database. Once done it'll redirect the
user to the folder the image was in (so the user can see that the
image has gone).

Requires a valid user to be logged in (will redirect to login page
otherwise).

If the image cannot be found it sends the user to a "Page not found"
message.

=cut

sub delete :Local :Args(1) :LoggedIn {
    my ($self, $c, $id) = @_;

    # Find the image in the database
    my $record = $c->model("DB")->resultset("Image")->find(0 + $id);

    # No image? Alert the user
    $c->detach("Lemon::Controller::Root", "default") unless $record;

    # The user must own the folder to delete the image.
    if ($c->user->get("id") != $record->folder->owner->id) {
        $c->detach("Lemon::Controller::Root", "error", [ $c->loc("You must own the image to delete it.") ]);
    }

    # Look up the containing folder ID for later
    my $folder = $record->folder;

    # Actually delete the image
    $record->delete;

    # Now send the user to the folder the image was in
    $c->detach("Lemon::Controller::Folders", "view_folder_by_id", [ $folder->id ]);
}

=head2 edit

Show the user the form for changing an image's description. Takes one
parameter, C<$id>, which is the ID of the the image to be amended.

Requires a valid user to be logged in (will redirect to login page
otherwise).

If the image cannot be found it sends the user to a "Page not found"
message.

=cut

sub edit :Local :Args(1) :LoggedIn {
    my ($self, $c, $id) = @_;

    # Find the image in the database
    my $record = $c->model("DB")->resultset("Image")->find(0 + $id);

    # No image? Alert the user
    $c->detach("Lemon::Controller::Root", "default") unless $record;

    # The user must own the folder to edit the image.
    if ($c->user->get("id") != $record->folder->owner->id) {
        $c->detach("Lemon::Controller::Root", "error", [ $c->loc("You must own the image to edit it.") ]);
    }

    # Set up the template
    $c->stash(
        image    => $record,
        template => "images/edit.tt2"
    );
    $c->forward("Lemon::View::TT");
}

=head2 save

Processes the result of C<create> and actually inserts the image into
the database, along with metadata. Takes no action parameters but
scans C<< $c->req->param >> for form parameters. Once uploaded it'll
issue a redirect to the view for the containing folder (to display
the just-uploaded image).

Requires a valid user to be logged in (will redirect to login page
otherwise).

=cut

sub save :Local :Args(0) :LoggedIn {
    my ($self, $c) = @_;

    # Check the folder exists - error if not
    my $folder = $c->model("DB")->resultset("Folder")->find(
        $c->req->param("folder") + 0
    );
    $c->detach("Lemon::Controller::Root", "error", [ $c->loc("No such folder.") ])
        unless $folder;

    # The user must own the folder to create the image.
    if ($c->user->get("id") != $folder->owner->id) {
        $c->detach("Lemon::Controller::Root", "error", [ $c->loc("You must own the folder to edit it.") ]);
    }

    # Create the new record
    my $record = $c->model("DB")->resultset("Image")->new({
        created   => DateTime->now(),
        folder    => $folder->id,                    # ID of folder
        content   => $c->req->upload("file")->slurp, # Slurp uploaded file
        title     => $c->req->param("title"),        # String description
        mime_type => $c->req->upload("file")->type   # MIME type of upload
    });

    # And actually insert it
    $record->insert;

    # And bounce the user back to the folder
    $c->detach("Lemon::Controller::Folders", "view_folder_by_id", [ $folder->id ]);
}

=head2 thumbnail

Display an image full-size. This returns the raw image data as it
was uploaded before. The response MIME type is also set to the
originally provided MIME type. Takes one parameter, C<$id>, the
integer ID of the image in the database.

If the image can't be found then a "Page not found" is displayed.

=cut

sub thumbnail :Local :Args(1) {
    my ($self, $c, $id) = @_;

    # Find the image in the database
    my $image = $c->model("DB")->resultset("Image")->find(0 + $id);

    # No image? Alert the user
    $c->detach("Lemon::Controller::Root", "default") unless $image;

    # Otherwise, success, set up the stash for the view
    $c->stash(
        mime_type   => $image->mime_type,
        body        => $image->content,
    );

    # ...and invoke the Thumbnail view to shrink it
    $c->forward("Lemon::View::Thumbnail");
}

=head2 update

Process the results of the C<edit> action by updating the image's
title. Once done, the user is redirected to the image's folder
for display.

Requires a valid user to be logged in (will redirect to login page
otherwise).

If the image can't be found then a "Page not found" is displayed.

=cut

sub update :Local :Args(0) :LoggedIn {
    my ($self, $c) = @_;

    # Find the image in the database
    my $record = $c->model("DB")->resultset("Image")->find(0 + $c->req->param("id"));

    # No image? Alert the user
    $c->detach("Lemon::Controller::Root", "default") unless $record;

    # The user must own the folder to edit the image.
    if ($c->user->get("id") != $record->folder->owner->id) {
        $c->detach("Lemon::Controller::Root", "error", [ $c->loc("You must own the image to edit it.") ]);
    }

    # Update the new record
    $record->title($c->req->param("title"));
    $record->update;

    # And bounce the user back to the folder
    $c->detach("Lemon::Controller::Folders", "view_folder_by_id", [ $record->folder->id ]);
}

=head2 view

Display an image full-size. This returns the raw image data as it
was uploaded before. The response MIME type is also set to the
originally provided MIME type. Takes one parameter, C<$id>, the
integer ID of the image in the database.

If the image can't be found then a "Page not found" is displayed.

=cut

sub view :Local :Args(1) {
    my ($self, $c, $id) = @_;

    # Find the image in the database
    my $image = $c->model("DB")->resultset("Image")->find(0 + $id);

    # No image? Alert the user
    $c->detach("Lemon::Controller::Root", "default") unless $image;

    # Otherwise, success, set up the stash for the view
    $c->stash(
        mime_type => $image->mime_type,
        body      => $image->content
    );

    # ...and invoke the Raw view to display content as-is
    $c->forward("Lemon::View::Raw");
}

=head1 SEE ALSO

=over

=item *

Lemon::Schema::Image

=back

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
