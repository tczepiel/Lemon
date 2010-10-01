package Lemon::Controller::Root;

use strict;
use utf8;
use warnings;

use parent 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in Lemon.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Lemon::Controller::Root - Root Controller for the Lemon picture
gallery system.

=head1 DESCRIPTION

Core actions which apply to all the objects, and general site
management.

=head1 METHODS

=cut

=head2 index

The main home page - displays the top-level folders for the user to
select from.

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    # Show the top-level folder
    $c->forward("/folders/view");
}

=head2 default

Catalyst comes here if no other action has been selected - we use this
to tell the user they've entered an invalid URI.

=cut

sub default :Path {
    my ($self, $c) = @_;

    # No action hit, so show an error
    $c->forward("error", [ $c->loc("Resource not found.") ]);
    $c->response->status(404); # For search engines and the like
}

=head2 error

An internal action for when the user does something wrong. We get
given a message (already localised) to display.

=cut

sub error :Private {
    my ($self, $c, $msg) = @_;

    $c->stash(
        template => "user_error.tt2",
        error    => $msg
    );
    $c->forward("Lemon::View::TT");
}

=head2 auto

An internal action that is run prior to all other site actions. We
check here that the database schema is configured and that there's a
user account configured (or else you could never create one).

Here is also where we check if the request's action carried a
":LoggedIn" attribute, in which case we verify the user is indeed
logged in.

=cut

sub auto :Private {
    my ($self, $c) = @_;

    # db_configured is a flag to reduce DB hits
    if (not $self->config->{db_configured}) {

        # Do we need to set up the database?
        $c->model("DB")->schema->deploy_if_required();

        # Mark database as good to go
        # We have to do it here or the user could never save their
        # data
        $self->config(db_configured => 1);

        # Set up an admin user if required
        if (not $c->model("DB")->schema->administrator_configured) {
            $c->forward("Lemon::Controller::Users", "create");
            return 0; # Stop processing
        }
    }

    # The :LoggedIn attribute is used against actions that require a
    # valid user to be logged in. If there isn't, this will catch the
    # request and direct the browser to the login page.
       if ($c->action and $c->action->attributes->{LoggedIn} and not $c->user_exists) {
        # Check user is logged in
        $c->forward("Lemon::Controller::Users", "must_login");
        return 0; # Stop processing
    }

    return 1; # Carry on!
}

=head2 end

Attempt to render a view, if needed. We shouldn't come here.

=cut

sub end :ActionClass('RenderView') {}

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
