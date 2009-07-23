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

has sequence => (
  is  => 'ro',
  isa => 'Config::MVP::Sequence',
  default    => sub { Config::MVP::Sequence->new },
  init_arg   => undef,
);

has starting_section_name => (
  is  => 'ro',
  isa => 'Str',
  builder => 'default_starting_section_name',
);

sub default_starting_section_name { '_' }

has starting_section_multivalue_args => (
  is  => 'ro',
  isa => 'ArrayRef',
  builder => 'default_starting_section_multivalue_args',
);

sub default_starting_section_multivalue_args { [] }

has _package_mva => (
  is  => 'ro',
  isa => 'HashRef[ArrayRef[Str]]',
  init_arg => undef,
  default  => sub { {} },
);

sub current_section {
  my ($self) = @_;

  my (@sections) = $self->sequence->sections;
  return $sections[ -1 ] if @sections;

  my $section = Config::MVP::Section->new({
    name            => $self->starting_section_name,
    multivalue_args => $self->starting_section_multivalue_args,
  });

  $self->sequence->add_section($section);
}

sub expand_package { $_[1] }

sub change_section {
  my ($self, $package_moniker, $name) = @_;

  $name = $package_moniker unless defined $name and length $name;
  
  my $package = $self->expand_package($package_moniker);

  # We already inspected this plugin.
  my $mva = $self->_package_mva->{ $package } ||= do {
    local $@;

    eval "require $package; 1"
      or confess "couldn't load plugin $name given in config: $@";

    $self->_package_mva->{$package} = [
      $package->can('multivalue_args') ? $package->multivalue_args : ()
    ];
  };

  my $section = Config::MVP::Section->new({
    name    => $name,
    package => $package,
    multivalue_args => $mva,
  });

  $self->sequence->add_section($section);
}

sub set_value {
  my ($self, $name, $value) = @_;

  $self->current_section->add_setting($name => $value);
}

no Moose;
1;
