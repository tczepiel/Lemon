package Lemon::View::Raw;

use strict;
use utf8;
use warnings;

use parent 'Catalyst::View';

=head1 NAME

Lemon::View::Raw - Catalyst View

=head1 DESCRIPTION

Catalyst View.

=head1 METHODS

=cut

=head2 process

Grabs content from the C<body> of the stash and sets the response body
to contain that data. C<mime_type> is grabbed from the stash and used
to set the response's Content-Type.

=cut

sub process {
    my ($self, $c) = @_;

    $c->response->content_type($c->stash->{mime_type});
    $c->response->body($c->stash->{body});
}

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
