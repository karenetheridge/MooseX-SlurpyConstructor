use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::Moose qw( with_immutable );
use Test::Deep;

{
    package Role;

    use Moose::Role;
    use MooseX::SlurpyConstructor;

    has thing  => ( is => 'rw' );
    has slurpy => ( is => 'ro', slurpy => 1);
}

{
    package Standard;

    use Moose;
    with 'Role';

    has 'thing' => ( is => 'rw' );
}

my @classes = qw( Standard );
with_immutable {

    my $obj;
    is(
        exception { $obj = Standard->new( thing => 1, bad => 99 ) },
        undef,
        'slurpy constructor doesn\'t die on unknown params',
    );
    cmp_deeply($obj->slurpy, { bad => 99 }, 'slurpy attr grabs unknown param');
}
@classes;

done_testing();
