use strict;
use warnings;

use lib 't/lib';

use Config::MVP::Reader::Finder;
use Path::Class;

my $dir = dir('t/eg');

my $config = Config::MVP::Reader::Finder->new->read_config({
  root     => $dir,
  basename => 'config',
});
