package Config::MVP::Assembler::WithBundles;
use Moose::Role;
# ABSTRACT: a role to make assemblers expand bundles

=head1 DESCRIPTION

Config::MVP::Assembler::WithBundles is a role to be composed into a
Config::MVP::Assembler subclass.  It allows some sections of configuration to
be treated as bundles.  When any section is ended, if that section represented
a bundle, its bundle contents will be unrolled and will replace it in the
sequence.

A package is considered a bundle if the this returns a defined method:

  my $method = $assembler->package_bundle_method($package);

The default implementation looks for a method callde C<mvp_bundle_config>, but
C<package_bundle_method> can be replaced to allow for other bundle-identifying
information.

Bundles are expanded by having their bundle method called like this:

  my @new_config = $bundle_section->package->$method({
    name    => $bundle_section->name,
    package => $bundle_section->package,
    payload => $bundle_section->payload,
  });

(We pass a hashref rather than a section so that bundles can be expanded
synthetically without having to laboriously create a new Section.)

The returned C<@new_config> is a list of arrayrefs, each of which has three
entries:

  [ $name, $package, $payload ]

Each arrayref is converted into a section in the sequence.

=cut

sub package_bundle_method {
  my ($self, $pkg) = @_;
  return unless $pkg->can('mvp_bundle_config');
  return 'mvp_bundle_config';
}

after end_section => sub {
  my ($self) = @_;

  my $seq = $self->sequence;

  my ($last) = ($seq->sections)[-1];
  return unless $last->package;
  return unless my $method = $self->package_bundle_method($last->package);

  $seq->delete_section($last->name);

  $self->_add_bundle_contents($method, {
    name    => $last->name,
    package => $last->package,
    payload => $last->payload,
  });
};

sub _add_bundle_contents {
  my ($self, $method, $arg) = @_;

  my @bundle_config = $arg->{package}->$method($arg);

  PLUGIN: for my $plugin (@bundle_config) {
    my ($name, $package, $payload) = @$plugin;

    Class::MOP::load_class($package);

    if (my $method = $self->package_bundle_method( $package )) {
      $self->_add_bundle_contents($method, {
        name    => $name,
        package => $package,
        payload => $payload,
      });
    } else {
      my $section = $self->section_class->new({
        name    => $name,
        package => $package,
      });

      # XXX: Clearly this is a hack. -- rjbs, 2009-08-24
      for my $name (keys %$payload) {
        my @v = ref $payload->{$name}
              ? @{$payload->{$name}}
              : $payload->{$name};
        $section->add_value($name => $_) for @v;
      }

      $self->sequence->add_section($section);
    }
  }
}

no Moose;
1;
