use inc::Module::Install;
name 'MyAggregator';
all_from 'lib/MyAggregator.pm';

# requires '';
requires 'Moose';
requires 'Test::Class';
requires 'Test::Exception';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
