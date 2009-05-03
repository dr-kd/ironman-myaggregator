package Test::MyAggregator;

use strict;
use warnings;
use base 'Test::Class';
use Test::Exception;
use Test::More;
#use LWP::UserAgent;

sub class { 'MyAggregator' }

sub context {
    {   dsn       => 'dbi:SQLite:dbname=/tmp/myaggregator.db',
        kioku_dir => 'dbi:SQLite:/tmp/mykioku.db',
    };
}

sub startup : Tests(startup => 2) {
    my $test = shift;
    use_ok $test->class, "use ok";
    `touch /tmp/myaggregator.db`;
    my $context = $test->context;
    my $dsn     = $context->{ dsn };
    my $schema  = MyModel->connect( $dsn );
    $schema->deploy;

    ok $schema->resultset( 'Feed' )->create(
        {   feedid => 1,
            url    => 'http://lumberjaph.net/blog/index.php/feed/',
        }
    ), "... insert one feed in the db";
}

sub shutdown : Tests(shutdown => 2) {
    my $test = shift;
    ok unlink '/tmp/myaggregator.db', '... unlink db test';
    ok unlink '/tmp/mykioku.db',      '... unlink kioku test';
}

sub constructor : Tests(1) {
    my $test = shift;
    can_ok $test->class, 'new';
}

sub dedupe_feed : Tests(4) {
    my $test = shift;

    my $context = $test->context;
    my $ua      = LWP::UserAgent->new;
    my $res     = $ua->get( "http://lumberjaph.net/blog/index.php/feed/" );

    ok my $obj = $test->class->new( context => $context ),
        "...  MyAggregator created";

    $obj->dedupe_feed( $res, 1 );

    my $schema = MyModel->connect( $context->{ dsn } );
    is $schema->resultset( 'Entry' )->search()->count, 10,
        '... 10 entries in the db';

    my $first = $schema->resultset( 'Entry' )->search()->first;
    my $res_kiokudb;
    $obj->kioku->txn_do(
        scope => 1,
        body  => sub {
            $res_kiokudb = $obj->kioku->lookup( $first->id );
        }
    );

    ok $res_kiokudb, '... got an object';
    is $res_kiokudb->permalink, $first->permalink, '... content is valid';
}

1;
