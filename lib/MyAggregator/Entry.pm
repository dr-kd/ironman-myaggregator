package MyAggregator::Entry;
use Moose;
use Digest::SHA qw(sha256_hex);
has 'author'  => ( is => 'rw', isa => 'Str' );
has 'content' => ( is => 'rw', isa => 'Str' );
has 'title'   => ( is => 'rw', isa => 'Str' );
has 'id'      => ( is => 'rw', isa => 'Str' );
has 'date'      => ( is => 'rw', isa => 'Str' );
has 'permalink' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    trigger  => sub {
        my $self = shift;
        $self->id( sha256_hex $self->permalink );
    }
);
1;
