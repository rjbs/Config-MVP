package Config::MVP::Reader::INI;
use Moose;
with qw(
  Config::MVP::Reader
  Config::MVP::Reader::Findable
);
# ABSTRACT: an MVP config reader for .ini files

use Config::INI::MVP::Reader;
  
=head1 DESCRIPTION
    
Config::MVP::Reader::INI reads F<.ini> files containing MVP-style
configuration.  It uses L<Config::INI::MVP::Reader> to do most of the heavy
lifting.
    
=cut

# Clearly this should be an attribute with a builder blah blah blah. -- rjbs,
# 2009-07-25
sub default_extension { 'ini' }

sub read_config {
  my ($self, $arg) = @_;
  my $config_file = $self->filename_from_args($arg);
  
  my $ini = Config::INI::MVP::Reader->new({ assembler => $self->assembler });
  $ini->read_file($config_file);
    
  # should be done in CIMR!! -- rjbs, 2009-08-24
  $self->assembler->end_section if $self->assembler->current_section;
      
  return $self->assembler->sequence;
} 
    
no Moose;
__PACKAGE__->meta->make_immutable;
1;

