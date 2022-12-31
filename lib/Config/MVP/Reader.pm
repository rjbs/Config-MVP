package Config::MVP::Reader;
# ABSTRACT: object to read config from storage into an assembler

use Moose;

use Config::MVP::Assembler;
use Cwd ();

=head1 SYNOPSIS

  use Config::MVP::Reader::YAML; # this doesn't really exist

  my $reader   = Config::MVP::Reader::YAML->new;

  my $sequence = $reader->read_config('/etc/foobar.yml');

=head1 DESCRIPTION

A Config::MVP::Reader exists to read configuration data from storage (like a
file) and convert that data into instructions to a L<Config::MVP::Assembler>,
which will in turn convert them into a L<Config::MVP::Sequence>, the final
product.

=attr add_cwd_to_lib

If true (which it is by default) then the current working directory will be
locally added to C<@INC> during config loading.  This helps deal with changes
made in Perl v5.26.1.

=cut

has add_cwd_to_lib => (
  is  => 'ro',
  isa => 'Bool',
  default => 1,
);

=method read_config

  my $sequence = $reader->read_config($location, \%arg);

This method is passed a location, which has no set meaning, but should be the
mechanism by which the Reader is told how to locate configuration.  It might be
a file name, a hashref of parameters, a DBH, or anything else, depending on the
needs of the specific Reader subclass.

It is also passed a hashref of arguments, of which there is only one valid
argument:

 assembler - the Assembler object into which to read the config

If no assembler argument is passed, one will be constructed by calling the
Reader's C<build_assembler> method.

Subclasses should generally not override C<read_config>, but should instead
implement a C<read_into_assembler> method, described below.  If a subclass
I<does> override C<read_config> it should take care to respect the
C<add_cwd_to_lib> attribute, above.

=cut

sub read_config {
  my ($self, $location, $arg) = @_;
  $arg ||= {};

  $self = $self->new unless blessed $self;

  my $assembler = $arg->{assembler} || $self->build_assembler;

  my $cwd = Cwd::getcwd();
  my $added_cwd;

  # Not using local @INC so as not to throw away intended changes to @INC
  # during the call to read_into_assembler.
  if ($self->add_cwd_to_lib && !grep {; $_ eq $cwd } @INC) {
    push @INC, $cwd;
    $added_cwd = 1;
  }

  $self->read_into_assembler($location, $assembler);

  if ($added_cwd) {
    @INC = grep{; $_ ne $cwd } @INC;
  }

  return $assembler->sequence;
}

=method read_into_assembler

This method should not be called directly.  It is called by C<read_config> with
the following parameters:

  my $sequence = $reader->read_into_assembler( $location, $assembler );

The method should read the configuration found at C<$location> and use it to
instruct the C<$assembler> (a L<Config::MVP::Assembler>) what configuration to
perform.

The default implementation of this method will throw an exception complaining
that it should have been implemented by a subclass.

=cut

sub read_into_assembler {
  confess 'required method read_into_assembler unimplemented'
}

=method build_assembler

If no Assembler is provided to C<read_config>'s C<assembler> parameter, this
method will be called on the Reader to construct one.

It must return a Config::MVP::Assembler object, and by default will return an
entirely generic one.

=cut

sub build_assembler { Config::MVP::Assembler->new; }

no Moose;
1;
