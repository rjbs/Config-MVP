#!perl
use strict;
use warnings;
use lib 't/lib';

use Test::More tests => 11;

require_ok( 'Config::MVP::Assembler' );

my $assembler = Config::MVP::Assembler->new;

my $section = Config::MVP::Section->new({
  name => '_',
});

$assembler->sequence->add_section($section);

$assembler->add_value(foo => 10);
$assembler->add_value(bar => 11);

$assembler->change_section('Foo::Bar');
$assembler->add_value(x => 10);
$assembler->add_value(y => 20);
$assembler->add_value(y => 30);
$assembler->add_value(z => -123);

$assembler->change_section('Foo::Bar', 'baz');
$assembler->add_value(x => 1);

my @sections = $assembler->sequence->sections;

is(@sections, 3, "there are three sections");
is($sections[0]->name, '_');
is($sections[1]->name, 'Foo::Bar');
is($sections[2]->name, 'baz');

is($sections[0]->package, undef);
is($sections[1]->package, 'Foo::Bar');
is($sections[2]->package, 'Foo::Bar');

is_deeply($sections[0]->payload, { bar => 11, foo => 10 });
is_deeply($sections[1]->payload, { x => 10, y => [ 20, 30 ], z => -123 });
is_deeply($sections[2]->payload, { x => 1 });

