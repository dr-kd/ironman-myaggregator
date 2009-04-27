package Test::MyAggregator;

use strict;
use warnings;
use base 'Test::Class';
use Test::Exception;
use Test::More;

sub class { 'MyAggregator' }

sub startup : Tests(startup => 1) {
    my $test = shift;
    use_ok $test->class, "use ok";
}

sub shutdown : Tests(shutdown) {
    my $test = shift;
}

sub constructor : Tests(1) {
    my $test = shift;
    can_ok $test->class, 'new';
}

1;
