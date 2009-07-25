package Config::MVP::Section;
use Moose;
# ABSTRACT: one section of an MVP configuration sequence

=head1 DESCRIPTION

For the most part, you can just consult L<Config::MVP> or
L<Config::MVP::Assembler>.

Of particular note is the C<aliases> attribute.  It is a hashref.  If the
aliases hashref is:

  { x => y }

...then attempts to add a value for the name C<x> will add it for C<y> instead.

=cut

has name    => (is => 'ro', isa => 'Str',       required => 1);
has package => (is => 'ro', isa => 'ClassName', required => 0);

has multivalue_args => (
  is  => 'ro',
  isa => 'ArrayRef',
  default => sub { [] },
);

has payload => (
  is  => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default  => sub { {} },
);

has aliases => (
  is  => 'ro',
  isa => 'HashRef',
  default => sub { {} },
);

sub add_value {
  my ($self, $name, $value) = @_;

  my $alias = $self->aliases->{ $name };
  $name = $alias if defined $alias;

  my $mva = $self->multivalue_args;

  if (grep { $_ eq $name } @$mva) {
    my $array = $self->payload->{$name} ||= [];
    push @$array, $value;
    return;
  }

  if (exists $self->payload->{$name}) {
    Carp::croak "multiple values given for property $name in section "
              . $self->name;
  }

  $self->payload->{$name} = $value;
}

no Moose;
1;
