package Config::MVP;
use strict;
use warnings;
# ABSTRACT: multivalue-property package-oriented configuration

=head1 DESCRIPTION

MVP is a mechanism for loading configuration (or other information) for
libraries.

It is meant to build up a L<Config::MVP::Sequence|Config::MVP::Sequence>
object, which is an ordered collection of sections.  Sections are
L<Config::MVP::Section|Config::MVP::Section> objects.

Each section has a name and a payload (a hashref) and may be associated with a
package.  No two sections in a sequence may have the same name.

You may construct a sequence by hand, but it may be easier to use the
sequence-generating helper, L<Config::MVP::Assembler>.

Config::MVP was designed for systems that will load plugins, possibly each
plugin multiply, each with its own configuration.  For examples of Config::MVP
in use, you can look at L<Dist::Zilla|Dist::Zilla> or L<App::Addex|App::Addex>.

=cut

1;
