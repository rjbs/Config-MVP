package Config::MVP::Reader::Findable::ByExtension;
use Moose::Role;
# ABSTRACT: a Findable Reader that looks for files by extension

with qw(Config::MVP::Reader Config::MVP::Reader::Findable);

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

=method refined_location

This role provides a default implementation of the
L<C<refined_location>|Config::MVP::Reader::Findable/refined_location> method
required by Config::MVP::Reader.  It will return a filename based on the
original location, if a file exists matching that location plus the reader's
C<default_extension>.

=cut

sub refined_location {
  my ($self, $location) = @_;

  my $candidate_name = "$location." . $self->default_extension;
  return unless -r $candidate_name and -f _;
  return $candidate_name;
}

no Moose::Role;
1;
