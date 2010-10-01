#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'Lemon';
all_from 'lib/Lemon.pm';

requires 'Catalyst::Runtime' => '5.80013';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::I18N';
requires 'Catalyst::Plugin::I18N::Request';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'Catalyst::View::TT';
requires 'parent';
requires 'Config::General';
requires 'DateTime';
requires 'Digest::SHA1';
requires 'GD';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
