package Config::MVP::Section;
use Moose 0.91;

use Class::Load 0.06 ();
use Config::MVP::Error;

# ABSTRACT: one section of an MVP configuration sequence

=head1 DESCRIPTION

For the most part, you can just consult L<Config::MVP> to understand what this
class is and how it's used.

=attr name

This is the section's name.  It's a string, and it must be provided.

=cut

has name => (
  is  => 'ro',
  isa => 'Str',
  required => 1
);

=attr package

This is the (Perl) package with which the section is associated.  It is
optional.  When the section is instantiated, it will ensure that this package
is loaded.

=cut

has package => (
  is  => 'ro',
  isa => 'Str', # should be class-like string, but can't be ClassName
  required  => 0,
  predicate => 'has_package',
);

=attr multivalue_args

This attribute is an arrayref of value names that should be considered
multivalue properties in the section.  When added to the section, they will
always be wrapped in an arrayref, and they may be added to the section more
than once.

If this attribute is not given during construction, it will default to the
result of calling section's package's C<mvp_multivalue_args> method.  If the
section has no associated package or if the package doesn't provide that
method, it default to an empty arrayref.

=cut

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

=attr aliases

This attribute is a hashref of name remappings.  For example, if it contains
this hashref:

  {
    file => 'files',
    path => 'files',
  }

Then attempting to set either the "file" or "path" setting for the section
would actually set the "files" setting.

If this attribute is not given during construction, it will default to the
result of calling section's package's C<mvp_aliases> method.  If the
section has no associated package or if the package doesn't provide that
method, it default to an empty hashref.

=cut

has aliases => (
  is   => 'ro',
  isa  => 'HashRef',
  lazy => 1,
  default => sub {
    my ($self) = @_;

    return {} unless $self->has_package and $self->package->can('mvp_aliases');

    return $self->package->mvp_aliases;
  },
);

=attr payload

This is the storage into which properties are set.  It is a hashref of names
and values.  You should probably not alter the contents of the payload, and
should read its contents only.

=cut

has payload => (
  is  => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default  => sub { {} },
);

=attr is_finalized

This attribute is true if the section has been marked finalized, which will
prevent any new values from being added to it.  It can be set with the
C<finalize> method.

=cut

has is_finalized => (
  is  => 'ro',
  isa => 'Bool',
  traits   => [ 'Bool' ],
  init_arg => undef,
  default  => 0,
  handles  => { finalize => 'set' },
);

before finalize => sub {
  my ($self) = @_;

  confess "can't finalize a Config::MVP::Section that hasn't been sequenced"
    unless $self->sequence;
};

=attr sequence

This attributes points to the sequence into which the section has been
assembled.  It may be unset if the section has been created but not yet placed
in a sequence.

=cut

has sequence => (
  is  => 'ro',
  isa => 'Config::MVP::Sequence',
  weak_ref  => 1,
  predicate => '_sequence_has_been_set',
  reader    => '_sequence',
  writer    => '__set_sequence',
  clearer   => '_clear_sequence',
);

sub _set_sequence {
  my ($self, $seq) = @_;
  confess "can't change Config::MVP::Section's sequence after it's set"
    if $self->sequence;
  $self->__set_sequence($seq);
}

sub sequence {
  my ($self) = @_;
  return undef unless $self->_sequence_has_been_set;
  my $seq = $self->_sequence;

  unless (defined $seq) {
    confess "tried to access sequence for a Config::MVP::Section, "
          . "but it has been destroyed"
  }

  return $seq;
}

=method add_value

  $section->add_value( $name => $value );

This method sets the value for the named property to the given value.  If the
property is a multivalue property, the new value will be pushed onto the end of
an arrayref that will store all values for that property.

Attempting to add a value for a non-multivalue property whose value was already
added will result in an exception.

=cut

sub add_value {
  my ($self, $name, $value) = @_;

  confess "can't add values to finalized section " . $self->name
    if $self->is_finalized;

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

=method load_package

  $section->load_package($package, $plugin);

This method is used to ensure that the given C<$package> is loaded, and is
called whenever a section with a package is created.  By default, it delegates
to L<Class::Load>.  If the package can't be found, it calls the
L<missing_package> method.  Errors in compilation are not suppressed.

=cut

sub load_package {
  my ($self, $package, $plugin) = @_;

  Class::Load::load_optional_class($package)
    or $self->missing_package($plugin, $package);
}

=method missing_package

  $section->missing_package($package, $plugin);

This method is called when C<load_package> encounters a package that is not
installed.  By default, it throws an exception.

=cut

sub missing_package {
  my ($self, $package, $plugin) = @_ ;

  Config::MVP::Error->throw({
    ident   => 'package not installed',
    message => "$package (for plugin $plugin) does not appear to be installed",
  });
}

sub _BUILD_package_settings {
  my ($self) = @_;

  return unless defined (my $pkg = $self->package);

  confess "illegal package name $pkg" unless Params::Util::_CLASS($pkg);

  $self->load_package($pkg, $self->name);

  # We call these accessors for lazy attrs to ensure they're initialized from
  # defaults if needed.  Crash early! -- rjbs, 2009-08-09
  $self->multivalue_args;
  $self->aliases;
}

sub BUILD {
  my ($self) = @_;
  $self->_BUILD_package_settings;
}

no Moose;
1;
