package Lemon::View::Thumbnail;

use strict;
use utf8;
use warnings;

use parent 'Catalyst::View';

use GD;

=head1 NAME

Lemon::View::Thumbnail - Catalyst View

=head1 DESCRIPTION

Catalyst View.

=head1 METHODS

=cut


=head2 process

Takes an image stored in C<body> in the request stash and shrinks it
to a smaller image where the larger axis will be 200 pixels and the
shorter axis scaled to preserve the image's aspect ratio. The
image is stored in the response body as a JPEG image, with the response
MIME type set up as appropriate.

=cut

sub process {
    my ($self, $c) = @_;

    # Read the source image
    my $src = GD::Image->new($c->stash->{body});
    
    $c->forward("Lemon::Controller::Root", "error", [ $c->loc("Could not read the source image") ]) unless $src;

    # Calculate the thumbnail's dimentions
    my $target_x = $src->width > $src->height ? 200 : 200 * $src->width / $src->height;
    my $target_y = $src->height > $src->width ? 200 : 200 * $src->height / $src->width;

    # Create the destination image
    my $dest = GD::Image->new($target_x, $target_y, 1);
    
    $c->forward("Lemon::Controller::Root", "error", [ $c->loc("Could not create the thumbnail image") ]) unless $dest;

    # ...and scale the source into it
    $dest->copyResampled($src, 0, 0, 0, 0, $dest->width, $dest->height, $src->width, $src->height);

    # Free the source image as quickly as we can
    undef $src;

    # Put the destination image into the response object
    $c->response->content_type("image/jpeg");
    $c->response->body($dest->jpeg);
}

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
