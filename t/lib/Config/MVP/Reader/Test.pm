package Config::MVP::Reader::Test;
use Moose;
with qw(Config::MVP::Reader Config::MVP::Reader::Findable);

sub default_extension { 'mvp-test' }

sub read_config {
  my ($self, $arg) = @_;

  my $filename = $self->filename_from_args($arg);

  open my $fh, '<', $filename or die "can't read $filename: $!";

  LINE: while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ m{\A\s*(;.+)?\z}; # skip blanks, comments

    if ($line =~ m{\A(\S+)\s*=\s*(\S+)\z}) {
      $self->assembler->add_value($1, $2);
      next LINE;
    }

    if ($line =~ m{\A\[(\S+)(?:\s+(\S+?))?\]\z}) {
      $self->assembler->change_section($1, $2);
      next LINE;
    }

    die "don't know how to handle this line: $line\n";
  }

  return $self->assembler->sequence;
}

1;
