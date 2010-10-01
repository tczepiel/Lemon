package Lemon::View::TT;

use strict;
use utf8;
use warnings;

use parent 'Catalyst::View::TT';

=head1 NAME

Lemon::View::TT - TT View for the Lemon picture gallery system

=head1 SYNOPSIS

See L<Lemon>

=head1 DESCRIPTION

Catalyst view for Template-Tooklit templates.

=head1 METHODS

=cut

__PACKAGE__->config({
    INCLUDE_PATH => [
        Lemon->path_to('root', 'src'),
        Lemon->path_to('root', 'lib')
    ],
    PRE_PROCESS  => 'site/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0,
    ENCODING     => 'utf-8'
});

=head2 process

Process the template as normal but setting the Vary HTTP header, to
cover the localisation.

=cut

sub process {
    my $self = shift;
    my ($c) = @_;

    # We do i18n based on Accept-Language
    $c->response->headers->push_header('Vary' => 'Accept-Language');
    $self->SUPER::process(@_);
}

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

