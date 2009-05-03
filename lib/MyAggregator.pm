package MyAggregator;
use feature ':5.10';
use MyModel;
use Moose;
use MyAggregator::Entry;
use KiokuDB;
use Digest::SHA qw(sha256_hex);

with 'MyAggregator::Roles::UserAgent', 'MyAggregator::Roles::Feed';

has 'context' => ( is => 'ro', isa => 'HashRef' );
has 'schema' => (
    is      => 'ro',
    isa     => 'Object',
    lazy    => 1,
    default => sub { MyModel->connect( $_[0]->context->{ dsn } ) },
);
has 'kioku' => (
    is      => 'rw',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
        my $self = shift;
        KiokuDB->connect( $self->context->{ kioku_dir }, create => 1 );
    }
);

sub run {
    my $self = shift;

    my $feeds = $self->schema->resultset( 'Feed' )->search();
    while ( my $feed = $feeds->next ) {
        my $res = $self->fetch_feed( $feed->url );
        if ( !$res || !$res->is_success ) {
            say "can't fetch " . $feed->url;
        } else {
            $self->dedupe_feed( $res, $feed->id );
        }
    }
}

sub dedupe_feed {
    my ( $self, $res, $feed_id ) = @_;

    my $feed = $self->feed_parser( \$res->content );
    return if ( !$feed );
    foreach my $entry ( $feed->entries ) {
        next if $self->schema->resultset( 'Entry' )->find( sha256_hex $entry->link );
        my $meme = MyAggregator::Entry->new(
            permalink => $entry->link,
            title     => $entry->title,
            author    => $entry->author,
            date      => $entry->issued,
            content   => $entry->content->body,
        );
        $self->kioku->txn_do(
            scope => 1,
            body  => sub {
                $self->kioku->insert( $meme->id => $meme );
            }
        );
        $self->schema->txn_do(
            sub {
                $self->schema->resultset( 'Entry' )->create(
                    {   entryid   => $meme->id,
                        permalink => $meme->permalink,
                        feedid    => $feed_id,
                    }
                );
            }
        );
    }
}

1;
