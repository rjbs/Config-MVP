package Config::MVP::Reader::Findable;
use Moose::Role;
# ABSTRACT: a config class that Config::MVP::Reader::Finder can find

=head1 DESCRIPTION

Config::MVP::Reader::Findable is a role meant to be composed alongside
Config::MVP::Reader.

=method refined_location

This method is used to decide whether a Findable reader can read a specific
thing under the C<$location> argument passed to C<read_config>.  The location
could be a directory or base file name or dbh or almost anything else.  This
method will return false if it can't find anything to read.  If it can find
something to read, it will return a new (or unchanged) value for C<$location>
to be used in reading the config.

=cut

requires 'refined_location';

no Moose::Role;
1;

