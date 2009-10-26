package Config::MVP::Reader::Finder;
use Moose;
with qw(Config::MVP::Reader);
# ABSTRACT: a reader that finds an appropriate file

use Module::Pluggable::Object;

sub default_search_path {
  return qw(Config::MVP::Reader)
}

has module_pluggable_object => (
  is => 'ro',
  init_arg => undef,
  default  => sub {
    my ($self) = @_;
    Module::Pluggable::Object->new(
      search_path => [ $self->default_search_path ],
      inner       => 0,
      require     => 1,
    );
  },
);

sub _which_plugin {
  my ($self, $arg) = @_;

  my @plugins = grep { $_->can_be_found($arg) }
                grep { $_->does('Config::MVP::Reader::Findable') }
                grep { $_->isa('Moose::Object') } # no roles!
                $self->module_pluggable_object->plugins;

  my @orig = $self->module_pluggable_object->plugins;

  confess "no viable configuration could be found" unless @plugins;
  confess "multiple possible config plugins found: @plugins" if @plugins > 1;

  return $plugins[0];
}     

sub read_config {
  my ($self, $arg) = @_;

  my $plugin = $self->_which_plugin($arg);

  return $plugin->new({ assembler => $self->assembler })->read_config($arg);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
