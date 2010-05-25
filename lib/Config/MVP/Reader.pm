package Config::MVP::Reader;
use Moose::Role;
# ABSTRACT: role to load MVP-style config from a file

use Config::MVP::Assembler;

=head1 DESCRIPTION

The config role provides some helpers for writing a configuration loader using
the L<Config::MVP|Config::MVP> system to load and validate its configuration.
It delegates assembly of the configuration sequence to an Assembler.  The
Reader is responsible for opening, reading, and interpreting a file.

=method build_assembler

If no Assembler is provided to C<read_config>'s C<assembler> parameter, this
method will be called on the Reader to construct one.

It must return a Config::MVP::Assembler object, and by default will return an
entirely generic one.

=cut

sub build_assembler { Config::MVP::Assembler->new; }

=method read_config

  my $sequence = $reader->read_config($location, \%arg);

=cut

sub read_config {
  my ($self, $location, $arg) = @_;
  $arg ||= {};

  my $assembler = $arg->{assembler} || $self->build_assembler;

  $self->read_into_assembler($location, $assembler);
}

requires 'read_into_assembler';

no Moose::Role;
1;
