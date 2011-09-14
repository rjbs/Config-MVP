use strict;
use warnings;

use Test::More;

# ABSTRACT: Test for 'mvp_multivalue_arg_test' feature

require Config::MVP::Assembler;
require Config::MVP::Section;

my $assembler = Config::MVP::Assembler->new();
{
  package Plugin;

  sub mvp_multivalue_arg_test {
    return 1;
  }
  1;
}
my $section = Config::MVP::Section->new({
    name => '_',
    package => 'Plugin',
});

$assembler->sequence->add_section($section);

$assembler->add_value('foo' => 10 );
$assembler->add_value('bar' => 11 );
$assembler->add_value('bar' => 12 );

$assembler->finalize();

my @sections = $assembler->sequence->sections;

is( @sections , 1 , 'there is 1 section');
is( $sections[0]->name , '_' , 'Name is expected _ ');
is( $sections[0]->package, 'Plugin', 'Hand constructed section has a Plugin');
is_deeply( $sections[0]->payload , { foo => [10], bar => [11,12] }, 'Payload matches expectation');

done_testing;


