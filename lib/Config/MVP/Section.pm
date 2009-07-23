package Config::MVP::Section;
use Moose;
# ABSTRACT: one section of an MVP configuration sequence

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

sub add_setting {
  my ($self, $name, $value) = @_;

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
