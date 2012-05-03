use strictures 1;
use Test::More;

BEGIN {
  package Method::Generate::Accessor::Role::ArrayRefInstance;

  use Moo::Role;

  sub _generate_simple_get {
    my ($self, $me, $name, $spec) = @_;
    "${me}->[${\$spec->{index}}]";
  }

  sub _generate_core_set {
    my ($self, $me, $name, $spec, $value) = @_;
    "${me}->[${\$spec->{index}}] = $value";
  }

  sub _generate_simple_has {
    my ($self, $me, $name, $spec) = @_;
    "defined ${me}->[${\$spec->{index}}]";
  }

  sub _generate_simple_clear {
    my ($self, $me, $name, $spec) = @_;
    "undef(${me}->[${\$spec->{index}}])";
  }

  sub generate_multi_set {
    my ($self, $me, $to_set, $from, $specs) = @_;
    "\@{${me}}[${\join ', ', map $specs->{$_}{index}, @$to_set}] = $from";
  }

  sub _generate_xs {
    my ($self, $type, $into, $name, $slot, $spec) = @_;
    require Class::XSAccessor::Array;
    Class::XSAccessor::Array->import(
      class => $into,
      $type => { $name => $spec->{index} }
    );
    $into->can($name);
  }

  sub default_construction_string { '[]' }
}

{
  package ArrayTest1;

  use Moo;

  BEGIN {
     Moo::Role->apply_roles_to_object(
       Moo->_accessor_maker_for(__PACKAGE__),
      'Method::Generate::Accessor::Role::ArrayRefInstance'
     )
  }

  has one => (is => 'ro');
  has two => (is => 'ro');
  has three => (is => 'ro');
}

my $o = ArrayTest1->new(one => 1, two => 2, three => 3);

is_deeply([ @$o ], [ 1, 2, 3 ], 'Basic object ok');

{
  package ArrayTest2;

  use Moo;

  extends 'ArrayTest1';

  has four => (is => 'ro');
}

$o = ArrayTest2->new(one => 1, two => 2, three => 3, four => 4);

is_deeply([ @$o ], [ 1, 2, 3, 4 ], 'Subclass object ok');

done_testing;
