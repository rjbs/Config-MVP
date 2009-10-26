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

Bundles are expanded by having their bundle method called.  The arguments
passed to this method B<are likely to change>.  Currently, it's passed a
hashref containing the bundle section's payload and a C<plugin_name> entry with
the section name.

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

  my @bundle_config = $last->package->$method({
    plugin_name => $last->name,
    %{ $last->payload },
  });

  for my $plugin (@bundle_config) {
    my ($name, $package, $payload) = @$plugin;

    my $section = $self->section_class->new({
      name    => $name,
      package => $package,
    });

    Carp::confess('bundles may not include bundles')
      if defined $self->package_bundle_method( $package );

    # XXX: Clearly this is a hack. -- rjbs, 2009-08-24
    for my $name (keys %$payload) {
      my @v = ref $payload->{$name} ? @{$payload->{$name}} : $payload->{$name};
      $section->add_value($name => $_) for @v;
    }

    $self->sequence->add_section($section);
  }
};

no Moose;
1;
