package Test::TestObject;

use Moose;
with 'MyAggregator::Roles::Feed', 'MyAggregator::Roles::UserAgent';
1;
