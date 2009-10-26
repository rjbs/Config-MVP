package Foo::Boondle;

sub mvp_bundle_config {
  return (
    [ 'boondle_1', 'Foo::Boo1', { x => 1 } ],
    [ 'boondle_2', 'Foo::Boo2', { a => 0 } ],
  );
}

1;
