package MyAggregator::Roles::UserAgent;
use Moose::Role;
use LWP::UserAgent;
use Cache::FileCache;
use URI;

has 'ua' => (
    is      => 'ro',
    isa     => 'Object',
    lazy    => 1,
    default => sub { LWP::UserAgent->new( agent => 'MyUberAgent' ); }
);
has 'cache' => (
    is   => 'rw',
    isa  => 'Cache::FileCache',
    lazy => 1,
    default =>
        sub { Cache::FileCache->new( { namespace => 'myaggregator', } ); }
);

sub fetch_feed {
    my ( $self, $url ) = @_;

    my $req = HTTP::Request->new( GET => URI->new( $url ) );
    my $ref = $self->cache->get( $url );
    if ( defined $ref && $ref->{ LastModified } ne '' ) {
        $req->header( 'If-Modified-Since' => $ref->{ LastModified } );
    }

    my $res = $self->ua->request( $req );
    $self->cache->set(
        $url,
        {   ETag         => $res->header( 'Etag' )          || '',
            LastModified => $res->header( 'Last-Modified' ) || ''
        },
        '5 days',
    );
    $res;
}

1;
