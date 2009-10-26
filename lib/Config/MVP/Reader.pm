package Config::MVP::Reader;
use Moose::Role;
# ABSTRACT: stored configuration loader role

use Config::MVP::Assembler;

=head1 DESCRIPTION

The config role provides some helpers for writing a configuration loader using
the L<Config::MVP|Config::MVP> system to load and validate its configuration.

=attr assembler

The L<assembler> attribute must be a Config::MVP::Assembler, has a sensible
default that will handle the standard needs of a config loader.  Namely, it
will be pre-loaded with a starting section for root configuration.  That
starting section will alias C<author> to C<authors> and will set that up as a
multivalue argument.

=cut

has assembler => (
  is   => 'ro',
  isa  => 'Config::MVP::Assembler',
  lazy => 1,
  builder => 'build_assembler',
);

sub build_assembler { Config::MVP::Assembler->new; }

requires 'read_config';

no Moose::Role;
1;

