package Lemon::Controller::Folders;

use strict;
use utf8;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

Lemon::Controller::Folders - Catalyst Controller for folder handling
in the Lemon picture gallery system.

=head1 DESCRIPTION

These Catalyst actions control the creation, editing, viewing and
deletion of folders.

=head1 METHODS

=cut


=head2 index

List the top-level folders using L<view>.

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    $c->forward("view");
}

=head2 create

Show the user the form for creating a new folder. Takes one parameter,
C<$parent>, which is the ID of the folder the image should be a child
of ($parent may be undefined for new top-level folders).

Requires a valid user to be logged in (will redirect to login page
otherwise).

=cut

sub create :Local :Args(1) :LoggedIn {
    my ($self, $c, $parent) = @_;

    # Build a hash of all users to set ownership
    my %users = map { $_->id => $_->email } $c->model("DB")->resultset("User")->all();

    # Set up the template
    $c->stash(
        parent   => $parent,
        template => "folders/edit.tt2",
        users    => \%users
    );
    $c->forward("Lemon::View::TT");
}

=head2 delete

Deletes a folder. This actually does a database delete so the image
cannot be recovered afterwards. Takes one parameter, C<$id>, the
integer ID of the folder in the database. The folder must be empty
before it can be deleted. Once done it'll redirect the user to the
parent folder (so the user can see that the folder has gone).

Requires a valid user to be logged in (will redirect to login page
otherwise).

If the folder cannot be found it sends the user to a "Page not found"
message.

=cut

sub delete :Local :Args(1) :LoggedIn {
    my ($self, $c, $id) = @_;

    # Find the folder in the database
    my $folder = $c->model("DB")->resultset("Folder")->find(0 + $id);

    # No folder? Alert the user
    $c->detach("Lemon::Controller::Root", "default") unless $folder;

    # The user must own the folder to delete it
    if ($c->user->get("id") != $folder->owner->id) {
        $c->detach("Lemon::Controller::Root", "error", [ $c->loc("You must own the folder to delete it.") ]);
    }

    # Check all subfolders are gone
    if ($folder->subfolders->count > 0) {
        $c->detach("Lemon::Controller::Root", "error", [ $c->loc("Folder must be empty to delete it.") ]);
    }

    # Check all images are gone
    if ($c->model("DB")->resultset("Image")->search({ folder => $folder->id })->count > 0) {
        $c->detach("Lemon::Controller::Root", "error", [ $c->loc("Folder must be empty to delete it.") ]);
    }

    # Parent folder for redirection after the delete
    my $parent = $folder->parent ? $folder->parent->id : undef;

    # Actually do the delete
    $folder->delete;

    # And direct the user to the parent folder
    $c->detach("view_folder_by_id", $parent);
}

=head2 edit

Allow the user to edit a folder by displaying the edit form. Takes one
parameter, C<$id>, the integer ID of the folder in the database.

Requires a valid user to be logged in (will redirect to login page
otherwise).

If the folder cannot be found it sends the user to a "Page not found"
message.

=cut

sub edit :Local :Args(1) :LoggedIn {
    my ($self, $c, $id) = @_;

    # Find the folder in the database
    my $folder = $c->model("DB")->resultset("Folder")->find(0 + $id);

    # No folder? Alert the user
    $c->detach("Lemon::Controller::Root", "default") unless $folder;

    # The user must own the folder to edit it
    if ($c->user->get("id") != $folder->owner->id) {
        $c->detach("Lemon::Controller::Root", "error", [ $c->loc("You must own the folder to edit it.") ]);
    }

    # Build a hash of all users to set ownership
    my %users = map { $_->id => $_->email } $c->model("DB")->resultset("User")->all();

    # Set up the template
    $c->stash(
        folder   => $folder,
        template => "folders/edit.tt2",
        users    => \%users
    );
    $c->detach("TT");
}

=head2 save

This action handles the results of them forms from both L<create> and
L<edit>. Takes no parameters but inspects L<< $c->req->param() >> to
find the form data. Once done the user will be shown the parent
folder to view the newly-created child.

Requires a valid user to be logged in (will redirect to login page
otherwise).

If the folder cannot be found in response to an edit it sends the user
to a "Page not found" message.

=cut

sub save :Local :Args(0) :LoggedIn {
    my ($self, $c) = @_;

    # We'll fill in the record as appropriate
    my $record;

    if (my $id = $c->req->param("id")) {
        # Editing an existing folder

        # Fetch the record
        $record = $c->model("DB")->resultset("Folder")->find(0 + $id);

        # No folder? Alert the user
        $c->detach("Lemon::Controller::Root", "default") unless $record;

        # The user must own the folder to edit it
        if ($c->user->get("id") != $record->owner->id) {
            $c->detach("Lemon::Controller::Root", "error", [ $c->loc("You must own the folder to edit it.") ]);
        }

    } elsif (my $parent = $c->req->param("parent")) {
        # A new record is being inserted

        # The user must own the parent to create it
        if ($parent ne "new") {
            my $folder = $c->model("DB")->resultset("Folder")->find(0 + $parent);

            # No parent folder? Alert the user
            $c->detach("Lemon::Controller::Root", "default") unless $folder;

            if ($c->user->get("id") != $folder->owner->id) {
                $c->detach("Lemon::Controller::Root", "error", [ $c->loc("You must own the parent folder to create a subfolder.") ]);
            }
        }

        # Create a new folder record
        $record = $c->model("DB")->resultset("Folder")->new({
            created => DateTime->now(),
        });

        # Set the parent relationship if not a top-level folder
        if ($parent ne "new") {
            $record->parent($parent + 0);
        }
    } else {
        # What are we meant to be doing?
        $c->detach("Lemon::Controller::Root", "error", [ $c->loc("No folder or parent ID provided!") ]);
    }

    # Check the short name is suitable
    if ($c->req->param("short_name") !~ m/^[A-Za-z0-9_]+$/) {
        $c->stash(error => $c->loc("Short name must be provided and consist of letters, numbers and underscores only."));
        $c->detach("/folders/edit")
    }

    # Title must contain something
    if ($c->req->param("title") !~ m/\S/) {
        $c->stash(error => $c->loc("Title must be provided."));
        $c->detach("/folders/edit")
    }

    # Folder owner must contain something
    if ($c->req->param("owner") !~ m/^\d+$/) {
        $c->stash(error => $c->loc("Owner must be provided."));
        $c->detach("/folders/edit")
    }

    # Set the fields
    $record->owner(                $c->req->param("owner"));
    $record->short_name(           $c->req->param("short_name"));
    $record->title(                $c->req->param("title"));
    $record->description(          $c->req->param("description"));
    $record->description_mime_type($c->req->param("description_mimetype"));
    if ($c->req->param("css")) {
        $record->custom_css($c->req->param("css"));
    } else {
        $record->custom_css(undef); # Prefer NULL
    }

    # And do the database operation
    $record->in_storage ? $record->update : $record->insert;

    # And lets go view the parent folder to show the newly created one
    $c->detach("view_folder_by_id",
        $record->parent ? $record->parent->id : undef);
}

=head2 view

View a folder, displaying subfolders and images in the folder. Takes a list
of folder short_names and looks up the path in the folder tree.

If the folder cannot be found in response to an edit it sends the user
to a "Page not found" message.

=cut

sub view :Local :Args {
    my ($self, $c, @args) = @_;

    # Will store the ID of the folder we're displaying
    my $folder_id;

    # Was a path specified? (ie. not top-level)
    if (my @args_copy = @args) {
        # Pick off the next arg and look for a map
        while(my $arg = shift @args_copy) {
            if (my $record = $c->model("DB")->resultset("Folder")->search({ parent => $folder_id, short_name => $arg })->first) {
                # Hit, update how far down the tree we've got
                $folder_id = $record->id;
            } else {
                # Failed to find a match here
                $c->detach("Lemon::Controller::Root", "default");
            }
        }

        # If we get here, success
    }

    # If this is the virtual top-level folder and there's only one subfolder
    # then navigate straight to it (unless logged in - as we may want to
    # create a new top-level folder)
    if (not @args and not $c->user) {
        my $count = $c->model("DB")->resultset("Folder")->search({ parent => undef })->count();
        if ($count == 1) {
            my $folder = $c->model("DB")->resultset("Folder")->search({ parent => undef })->first;

            push @args, $folder->short_name;
            $folder_id = $folder->id;
        }
    }

    my @subfolders = $c->model("DB")->resultset("Folder")->search({ parent => $folder_id })->all();
    my $can_edit   = not(not($c->user));
    my @images;
    my $folder;

    # Top-level folder cannot contain images
    if (defined $folder_id) {
        $folder   = $c->model("DB")->resultset("Folder")->find($folder_id);
        @images   = $c->model("DB")->resultset("Image")->search({ folder => $folder_id })->all();
        warn("id1 = " . $c->user->get("id") . " and id2 = " . $folder->owner->id);
        $can_edit = ($c->user->get("id") == $folder->owner->id) if $c->user;
    }

    $c->stash(
        show_create => $can_edit,
        show_edit   => ($can_edit and defined $folder_id),
        folder_path => \@args,
        folder_id   => $folder_id,
        folder      => $folder,
        subfolders  => \@subfolders,
        images      => \@images,
        parent_path => join("/", splice(@args, 0, -1)), # trim off one level
        template    => "folders/view.tt2"
    );
    $c->detach("Lemon::View::TT");
}

=head2 view_folder_by_id

An internal action for generating a browser redirect to the canonical
URI for a given folder. The folder is specified as an integer ID via
the C<$id> parameter.

If the folder cannot be found in response to an edit it sends the user
to the top-level folder.

=cut

sub view_folder_by_id :Private {
    my ($self, $c, $id) = @_;

    # Where we'll store the short_names
    my @parts;

    # Top-level
    if (not defined $id) {
        $c->response->redirect($c->uri_for("/folders/view/"));
        $c->detach();
    }

    my $record = $c->model("DB")->resultset("Folder")->find($id);

    # No such ID?
    if (not $record) {
        $c->response->redirect($c->uri_for("/folders/view/"));
        $c->detach();
    }

    # Iterate to find the parts, leaf to trunk
    do {
        unshift @parts, $record->short_name;
    } while ($record->parent and $record = $record->parent);

    # And do the redirect
    $c->response->redirect($c->uri_for("/folders/view/" . join("/", @parts)));
    $c->detach();
}

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
