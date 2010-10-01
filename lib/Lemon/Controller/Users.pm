package Lemon::Controller::Users;

use strict;
use utf8;
use warnings;

use parent 'Catalyst::Controller';

use DateTime;
use Digest::SHA1 qw/sha1_base64/;

=head1 NAME

Lemon::Controller::Users - Catalyst Controller for user/administrator
handling in the Lemon picture gallery system.

=head1 DESCRIPTION

In Lemon a I<user> is a login, which comes with the ability to create
folders, add images to them and edit/delete folders and images. All
users can also create and edit other users.

These Catalyst actions control the creation, editing, listing and
deletion of users.

=head1 METHODS

=cut


=head2 index

An alias for L<list> - lists the users.

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->detach("list");
}

=head2 create

Create a new user account. If there are no users already on the system
then no login is required. Otherwise the user must be logged in to
create new accounts (and will be redirected to the login screen).

=cut

sub create :Local :Args(0) {
    my ($self, $c) = @_;

    if (not $c->model("DB")->schema->administrator_configured) {
        # First account creation
        $c->stash->{message} ||= $c->loc("Please set up an account now.");
    } elsif (not $c->user) {
        # Must authenticate first
        $c->detach("must_login");
    }

    # Set up the template
    $c->stash(template => "users/edit.tt2");
    $c->forward("Lemon::View::TT");
}

=head2 delete

Delete a user. The record is deleted from the database and cannot be
recovered. Takes one parameter, C<$id> which is the integer ID of the
user to be edited.

Requires a valid user to be logged in (will redirect to login page
otherwise).

=cut

sub delete :Local :Args(1) :LoggedIn {
    my ($self, $c, $id) = @_;

    # Look up the user in the database
    my $user = $c->model("DB")->resultset("User")->find(0 + $id);

    # No such user? Alert the caller
    $c->detach("Lemon::Controller::Root", "default") unless $user;

    # Actually delete the user
    $user->delete();

    # And show the user list
    $c->forward("list");
}

=head2 edit

Edit an existing user by displaying an edit form. Takes one parameter,
C<$id> which is the integer ID of the user to be edited.

Requires a valid user to be logged in (will redirect to login page
otherwise).

=cut

sub edit :Local :Args(1) :LoggedIn {
    my ($self, $c, $id) = @_;

    # Look up the user in the database
    my $user = $c->model("DB")->resultset("User")->find(0 + $id);

    # No such user? Alert the caller
    $c->detach("Lemon::Controller::Root", "default") unless $user;

    # Set up the template
    $c->stash(
        user     => $user,
        template => "users/edit.tt2"
    );
    $c->forward("Lemon::View::TT");
}

=head2 list

Lists all the users in the system.

Requires a valid user to be logged in (will redirect to login page
otherwise).

=cut

sub list :Local :Args(0) :LoggedIn {
    my ($self, $c) = @_;

    # Fetch the list of users
    my @users = $c->model("DB")->resultset("User")->search({}, { order_by => "email" })->all;

    # Set up the template
    $c->stash(
        users    => \@users,
        template => "users/list.tt2"
    );
    $c->forward("Lemon::View::TT");
}

=head2 login

Display the login form to the browser, and process the subsequent
login request. Takes no parameters.

=cut

sub login :Local :Args(0) {
    my ($self, $c) = @_;

    # Log out if already logged in
    $c->logout if $c->user;

    # Params from form?
    if (my $username = $c->req->param("username") and
        my $password = $c->req->param("password")) {

        # Try to log in
        $c->authenticate({ email => $username, password => $password });

        if ($c->user) {
            # Success, tell the user the good news
            $c->stash(template => "users/login_successful.tt2");
            $c->forward("Lemon::View::TT");
            $c->detach();
        } else {
            # Failed, show the form again
            $c->stash(error => $c->loc("Login unsuccessful. Please check the username and password."));
        }
    }

    # Set up the template
    $c->stash(template => "users/login.tt2");
    $c->forward("Lemon::View::TT");
}

=head2 logout

Logs out the logged in user, if any, and displays a logged out
confirmation. Takes no parameters.

=cut

sub logout :Local :Args(0) {
    my ($self, $c) = @_;

    # Do the logout if logged in
    $c->logout if $c->user;

    # Set up the template
    $c->stash(template => "users/logout.tt2");
    $c->forward("Lemon::View::TT");
}

=head2 must_login

An internal action used to prompt the user to log in where the action
require a logged in user. This displays the login form with a message
informing the user they must login to complete their action.

=cut

sub must_login :Private {
    my ($self, $c) = @_;

    $c->stash->{error} = $c->loc("You must be logged in to perform this action.");
    $c->forward("login");
}

=head2 save

Processes the result of the L<create> and L<edit> forms. Doesn't take
any arguments but scans C<< $c->req->params() >> to find data to save.

Requires a logged in user to do this unless the system has no users
(otherwise you could never create your first user).

=cut

sub save :Local :Args(0) {
    my ($self, $c) = @_;

    # Require logged-in user unless there aren't any
    if ($c->model("DB")->schema->administrator_configured) {
        $c->detach("must_login") unless $c->user;
    }

    # Will be populated by either of the next blocks
    my $record;

    if (my $id = $c->req->param("userID")) {
        # Update existing record, so find it in the database
        $record =$c->model("DB")->resultset("User")->find(0 + $id);

        # No such user? Alert the caller
        $c->detach("Lemon::Controller::Root", "default") unless $record;
    } else {
        # On edit the password box may be blank for "no change", but
        # on user creation we must have a password.
        if ($c->req->param("password") !~ m/\S/) {
            $c->stash->{error} = $c->loc("Password must be provided.");
            $c->detach("/users/edit")
        }

        # And create the new user's record
        $record = $c->model("DB")->resultset("User")->new({
            created => DateTime->now()
        });
    }

    # Check email address is set
    if ($c->req->param("email") !~ m/\S/) {
        $c->stash->{error} = $c->loc("Email address must be provided.");
        $c->detach("/users/edit")
    }

    # Check password confirmation matches the password
    if ($c->req->param("password") and $c->req->param("password") ne $c->req->param("passwordConfirm")) {
        $c->stash->{error} = $c->loc("The two passwords do not match.");
        $c->detach("/users/edit")
    }

    # Set the new values
    $record->email($c->req->param("email"));
    $record->password(sha1_base64($c->req->param("password"))) if $c->req->param("password");

    # Now save the record
    $record->in_storage ? $record->update : $record->insert;

    # Set up the template
    $c->stash(
        template  => "users/saved.tt2",
        login_now => not $c->user
    );
    $c->forward("Lemon::View::TT");
}

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
