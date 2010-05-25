package Config::MVP::Reader::Hash;
use Moose;
with qw(Config::MVP::Reader);
# ABSTRACT: a reader that tries to cope with a plain old hashref

=head1 SYNOPSIS

  my $sequence = Config::MVP::Reader::Hash->new->read_config( \%config );

=head1 DESCRIPTION

In some ways, this is the L<Config::MVP::Reader> of last resort.  Given a
hashref, it attempts to interpret it as a Config::MVP::Sequence.  Because
hashes are generally unordered, order can't be relied upon unless the hash tied
to have order (presumably with L<Tie::IxHash>).  The hash keys are assumed to
be section names and will be used as the section package moniker unless a
L<__package> entry is found.

=cut

sub read_into_assembler {
  my ($self, $location, $assembler) = @_;

  confess "no hash given to $self" unless my $hash = $location;

  for my $name (keys %$hash) {
    my $payload = { %{ $hash->{ $name } } };
    my $package = delete($payload->{__package}) || $name;

    $assembler->begin_section($package, $name);

    for my $key (%$payload) {
      my $val = $payload->{ $key };
      my @values = ref $val ? @$val : $val;
      $assembler->add_value($key => $_) for @values;
    }

    $assembler->end_section;
  }

  return $assembler->sequence;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
