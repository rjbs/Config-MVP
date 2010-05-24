package Config::MVP::Reader;
use Moose::Role;
# ABSTRACT: role to load MVP-style config from a file

use Config::MVP::Assembler;

=head1 DESCRIPTION

The config role provides some helpers for writing a configuration loader using
the L<Config::MVP|Config::MVP> system to load and validate its configuration.
It delegates assembly of the configuration sequence to an Assembler.  The
Reader is responsible for opening, reading, and interpreting a file.

=attr assembler

The L<assembler> attribute must be a Config::MVP::Assembler, has a sensible
default that will handle the standard needs of a config loader.  Namely, it
will be pre-loaded with a starting section for root configuration.

=cut

has assembler => (
  is   => 'ro',
  isa  => 'Config::MVP::Assembler',
  lazy => 1,
  builder => 'build_assembler',
);

=method build_assembler

This is the builder for the C<assembler> attribute and must return a
Config::MVP::Assembler object.  It's here so subclasses can produce assemblers
of other classes or with pre-loaded sections.

=cut

sub build_assembler { Config::MVP::Assembler->new; }

=method read_config

  my $sequence = $reader->read_config(\%arg);

This method, B<which must be implemented by classes including this role>, is
passed a hashref of arguments and returns a Config::MVP::Sequence.

Likely arguments include:

  root     - the name of the directory in which to look
  filename - the filename in that directory to read

=cut

requires 'read_config';

no Moose::Role;
1;
