package Config::MVP::Error;
use Moose;

has message => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
  lazy     => 1,
  default  => sub { $_->ident },
);

sub as_string {
  my ($self) = @_;
  join qq{\n}, $self->message, "\n", $self->stack_trace;
}

use overload (q{""} => 'as_string');

with(
  'Throwable',
  'Role::Identifiable::HasIdent',
  'Role::HasMessage',
  'StackTrace::Auto',
  'MooseX::OneArgNew' => {
    type     => 'Str',
    init_arg => 'ident',
  },
);

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
