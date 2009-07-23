package Config::MVP;
use strict;
use warnings;

=head1 NAME

Config::MVP - multivalue-property configuration

=head1 DESCRIPTION

MVP is a state machine for loading configuration (or other information) for
libraries.  It expects to generate a list of named sections, each of which
relates to a Perl namespace and contains a set of named parameters.

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2008 Ricardo SIGNES, all rights reserved.

This program is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
