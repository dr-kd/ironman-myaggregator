package MyAggregator::Roles::Feed;
use Moose::Role;
use XML::Feed;
use feature 'say';
sub feed_parser {
    my ( $self, $content ) = @_;
    my $feed = eval { XML::Feed->parse( $content ) };
    if ( $@ ) {
        my $error = XML::Feed->errstr || $@;
        say "error while parsing feed : $error";
    }
    $feed;
}
1;
