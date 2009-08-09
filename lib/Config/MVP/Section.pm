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
has package => (
  is  => 'ro',
  isa => 'Str', # should be class-like string, but can't be ClassName
  required  => 0,
  predicate => 'has_package',
);

has multivalue_args => (
  is   => 'ro',
  isa  => 'ArrayRef',
  lazy => 1,
  default => sub {
    my ($self) = @_;

    return []
      unless $self->has_package and $self->package->can('mvp_multivalue_args');

    return [ $self->package->mvp_multivalue_args ];
  },
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
  default => sub {
    my ($self) = @_;

    return {} unless $self->has_package and $self->package->can('mvp_aliases');

    return $self->package->mvp_aliases;
  },
);

sub _BUILD_package_settings {
  my ($self) = @_;

  return unless defined (my $pkg  = $self->package);

  # We already inspected this plugin.
  confess "illegal package name $pkg" unless Params::Util::_CLASS($pkg);

  my $name = $self->name;
  eval "require $pkg; 1"
    or confess "couldn't load plugin $name given in config: $@";

  # We call these accessors for lazy attrs to ensure they're initialized from
  # defaults if needed.  Crash early! -- rjbs, 2009-08-09
  $self->multivalue_args;
  $self->aliases;
}

sub BUILD {
  my ($self) = @_;
  $self->_BUILD_package_settings;
}

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
