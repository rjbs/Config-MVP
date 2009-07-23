package Config::MVP::Sequence;
use Moose;
# ABSTRACT: an ordered set of named configuration sections

use Tie::IxHash;
use Config::MVP::Section;

has sections => (
  isa => 'HashRef[Config::MVP::Section]',
  reader   => '_sections',
  init_arg => undef,
  default  => sub {
    tie my %section, 'Tie::IxHash';
    return \%section;
  },
);

sub section_named {
  my ($self, $name) = @_;
  my $sections = $self->_sections;

  return unless exists $sections->{ $name };
  return $sections->{ $name };
}

sub section_names {
  my ($self) = @_;
  return keys %{ $self->_sections };
}

sub sections {
  my ($self) = @_;
  return values %{ $self->_sections };
}

sub add_section {
  my ($self, $section) = @_;

  my $name = $section->name;
  confess "already have a section named $name" if $self->_sections->{ $name };

  $self->_sections->{ $name } = $section;
}

no Moose;
1;
