package Config::MVP::Assembler;
use Moose;
# ABSTRACT: multivalue-property config-loading state machine

use Config::MVP::Sequence;
use Config::MVP::Section;

=head1 DESCRIPTION

MVP is a state machine for loading configuration (or other information) for
libraries.  It expects to generate a list of named sections, each of which
relates to a Perl namespace and contains a set of named parameters.

=cut

has sequence_class => (
  is   => 'ro',
  isa  => 'ClassName',
  lazy => 1,
  default => 'Config::MVP::Sequence',
);

has section_class => (
  is   => 'ro',
  isa  => 'ClassName',
  lazy => 1,
  default => 'Config::MVP::Section',
);

has sequence => (
  is  => 'ro',
  isa => 'Config::MVP::Sequence',
  default  => sub { $_[0]->sequence_class->new },
  init_arg => undef,
);

sub current_section {
  my ($self) = @_;

  my (@sections) = $self->sequence->sections;
  return $sections[ -1 ] if @sections;

  return;
}

sub expand_package { $_[1] }

sub change_section {
  my ($self, $package_moniker, $name) = @_;

  $name = $package_moniker unless defined $name and length $name;

  my $package = $self->expand_package($package_moniker);

  # We already inspected this plugin.
  my $pkg_data = do {
    local $@;
    eval "require $package; 1"
      or confess "couldn't load plugin $name given in config: $@";

    {
      alias =>   eval { $package->mvp_aliases         } || {},
      multi => [ eval { $package->mvp_multivalue_args } ],
    };
  };

  my $section = $self->section_class->new({
    name    => $name,
    package => $package,
    aliases => $pkg_data->{alias},
    multivalue_args => $pkg_data->{multi},
  });

  $self->sequence->add_section($section);
}

sub set_value {
  my ($self, $name, $value) = @_;

  confess "can't set value without a section to work in"
    unless my $section = $self->current_section;

  $section->add_setting($name => $value);
}

no Moose;
1;
