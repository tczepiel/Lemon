package Lemon;

use strict;
use utf8;
use warnings;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application

use parent qw/Catalyst/;
use Catalyst qw/-Debug
                Authentication
                ConfigLoader
                I18N
                I18N::Request
                Session
                Session::State::Cookie
                Session::Store::FastMmap
                Static::Simple
                Unicode::Encoding/;
our $VERSION = '1.00';

# Configure the application.
#
# Note that settings in lemon.conf (or other external
# configuration file that you set up manually) take precedence
# over this.

__PACKAGE__->config(
    name     => 'Lemon',
    encoding => 'UTF-8'
);

# Set up the authentication system.

__PACKAGE__->config->{authentication} = {
    default_realm => 'members',
    realms => {
        members => {
            credential => {
                class              => 'Password',
                password_field     => 'password',
                password_type      => 'hashed',
                password_hash_type => 'SHA-1'
            },
            store => {
                class      => 'DBIx::Class',
                user_model => 'DB::User',
            }
        }
    }
};

# Start the application
__PACKAGE__->setup();

=head1 NAME

Lemon - Catalyst based picture gallery

=head1 SYNOPSIS

    script/lemon_server.pl

=head1 DESCRIPTION

A L<Catalyst>-based image gallery website with i18n support.

=head1 SEE ALSO

L<Lemon::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Luke Ross

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
