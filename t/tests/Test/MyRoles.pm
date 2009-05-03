package Test::MyRoles;

use strict;
use warnings;
use base 'Test::Class';
use Test::Exception;
use Test::More;

sub class { 'Test::TestObject' }

sub url { "http://lumberjaph.net/blog/index.php/feed/" }

sub startup : Tests(startup => 1) {
    my $test = shift;
    use_ok $test->class, "use ok";
    `rm -rf /tmp/FileCache/myaggregator/`;
}

sub constructor : Tests(1) {
    my $test = shift;
    can_ok $test->class, 'new';
}

sub fetch_feed : Tests(5) {
    my $test = shift;
    can_ok $test->class, 'fetch_feed';

    ok my $obj = $test->class->new(), '... object is created';
    my $res = $obj->fetch_feed( $test->url );
    is $res->code,      "200",          "... fetch is a success";
    like $res->content, qr/lumberjaph/, "... and content is good";

    # now data should be in cache
    my $ref = $obj->cache->get( $test->url );
    ok defined $ref, "... url is now in cache";
}

sub feed_parser : Tests(3) {
    my $test = shift;
    can_ok $test->class, 'feed_parser';

    my $ua  = LWP::UserAgent->new;
    my $res = $ua->get( $test->url );
    ok my $obj = $test->class->new(), "... object is created";
    my $feed = $obj->feed_parser( \$res->content );
    isa_ok $feed, "XML::Feed::Format::RSS";
}

1;
