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

use Path::Class;

my $dir = dir('t/eg');

my $config = CMRFB->new->read_config({
  root     => $dir,
  basename => 'config',
});

my @sections = $config->sections;

is(@sections, 5, "there are five sections");

my ($bar, $baz, $b_1, $b_2, $quux) = @sections;

is($bar->name,     'Foo::Bar',  '1st is Foo::Bar (name)');
is($bar->package,  'Foo::Bar',  '1st is Foo::Bar (pkg)');

is($baz->name,     'bz',        '2nd is bz (name)');
is($baz->package,  'Foo::Baz',  '2nd is Foo::Baz (pkg)');

is($b_1->name,     'boondle_1', '2nd is boondle_1 (name)');
is($b_1->package,  'Foo::Boo1', '2nd is Foo::Boo1 (pkg)');

is($b_2->name,     'boondle_2', '2nd is boondle_2 (name)');
is($b_2->package,  'Foo::Boo2', '2nd is Foo::Boo2 (pkg)');

is($quux->name,    'Foo::Quux', '3rd is Foo::Quux (name)');
is($quux->package, 'Foo::Quux', '3rd is Foo::Quux (pkg)');

done_testing;
