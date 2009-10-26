package Config::MVP::Reader::Findable;
use Moose::Role;
# ABSTRACT: a config class that Config::MVP::Reader::Finder can find

=head1 DESCRIPTION

Config::MVP::Reader::Findable is a role meant to be composed alongside
Config::MVP::Reader.  It indicates to L<Config::MVP::Reader::Finder> that the
composing config reader can look in a directory and decide whether there's a
relevant file in the configuration root.

=cut

use File::Spec;

=method default_extension

This method, B<which must be composed by classes including this role>, returns
the default extension used by files in the format this reader can read.

When the Finder tries to find configuration, it have a directory root and a
basename.  Each (Findable) reader that it tries in turn will look for a file
F<basename.extension> in the root directory.  If exactly one file is found,
that file is read.

=cut

requires 'default_extension';

=method can_be_found

This method gets the same arguments as C<read_config> and returns true if this
config reader will be able to handle the request.

=cut

sub can_be_found {
  my ($self, $arg) = @_;

  my $config_file = $self->filename_from_args($arg);
  return -r "$config_file" and -f _;
}

=method filename_from_args

This method gets the same arguments as C<read_config> and will return the fully
qualified filename of the file it would want to read for configuration.  This
file is not guaranteed to exist or be readable.

=cut

sub filename_from_args {
  my ($self, $arg) = @_;

  # XXX: maybe we should detect conflicting cases -- rjbs, 2009-08-18
  my $filename;
  if ($arg->{filename}) {
    $filename = $arg->{filename}
  } else {
    my $basename = $arg->{basename};
    confess "no filename or basename supplied"
      unless defined $arg->{basename} and length $arg->{basename};

    my $extension = $self->default_extension;
    $filename = $basename;
    $filename .= ".$extension" if defined $extension;
  }

  return File::Spec->catfile("$arg->{root}", $filename);
}

no Moose::Role;
1;

