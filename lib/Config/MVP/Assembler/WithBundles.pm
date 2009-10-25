package Config::MVP::Assembler::WithBundles
use Moose::Role;
# ABSTRACT: a role to make assemblers expand bundles

after end_section => sub {
  my ($self) = @_;

  my $seq = $self->sequence;

  my ($last) = ($seq->sections)[-1];
  return unless $last->package;
  
  {
    local $@;
    return unless eval {
      $last->package->does('Config::MVP::Assembler::WithBundles::Bundle');
    }; 
  } 
      
  $seq->delete_section($last->name);
    
  my @bundle_config = $last->package->bundle_config({
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
      if $package->does('Config::MVP::Assembler::WithBundles::Bundle');

    # XXX: Clearly this is a hack. -- rjbs, 2009-08-24
    for my $name (keys %$payload) {
      my @v = ref $payload->{$name} ? @{$payload->{$name}} : $payload->{$name};
      $section->add_value($name => $_) for @v;
    }

    $self->sequence->add_section($section);
  }
};

sub expand_bundles {
  my ($self, $plugins) = @_;

  my @new_plugins;

  for my $plugin (@$plugins) {
    if (eval { $plugin->[1]->does('Config::MVP::Assembler::WithBundles::Bundle') }) {
    } else {
      push @new_plugins, $plugin;
    }
  }

  @$plugins = @new_plugins;
}

no Moose;
1;

