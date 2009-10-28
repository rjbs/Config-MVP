use strict;
use warnings;

use Test::More;

use lib 't/lib';

{
  package CMRFBA;
  use Moose;
  extends 'Config::MVP::Assembler';
  with 'Config::MVP::Assembler::WithBundles';
}

{
  package CMRFB;
  use Moose;
  extends 'Config::MVP::Reader::Finder';

  sub build_assembler { CMRFBA->new; }
}

my $config = CMRFB->new->read_config({
  root     => 't/eg',
  basename => 'config',
});

my @sections = $config->sections;

is(@sections, 6, "there are five sections");

my ($bar, $baz, $b_1, $b_2, $b_3, $quux) = @sections;

is($bar->name,     'Foo::Bar',  '1st is Foo::Bar (name)');
is($bar->package,  'Foo::Bar',  '1st is Foo::Bar (pkg)');

is($baz->name,     'bz',        '2nd is bz (name)');
is($baz->package,  'Foo::Baz',  '2nd is Foo::Baz (pkg)');

is($b_1->name,     'boondle_1', '2nd is boondle_1 (name)');
is($b_1->package,  'Foo::Boo1', '2nd is Foo::Boo1 (pkg)');

is($b_2->name,     'boondle_2', '2nd is boondle_2 (name)');
is($b_2->package,  'Foo::Boo2', '2nd is Foo::Boo2 (pkg)');

is($b_3->name,     'boondle_3', '3rd is boondle_3 (name)');
is($b_3->package,  'Foo::Boo2', '3rd is Foo::Boo2 (pkg)');

is($quux->name,    'Foo::Quux', '4th is Foo::Quux (name)');
is($quux->package, 'Foo::Quux', '4th is Foo::Quux (pkg)');

done_testing;
