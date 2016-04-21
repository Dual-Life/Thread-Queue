use strict;
use warnings;

BEGIN {
    if ($ENV{'PERL_CORE'}){
        chdir('t');
        unshift(@INC, '../lib');
    }
    use Config;
    if (! $Config{'useithreads'}) {
        print("1..0 # Skip: Perl not compiled with 'useithreads'\n");
        exit(0);
    }
}

use threads;
use threads::shared;
use Thread::Queue;

if ($] == 5.008) {
    require 't/test.pl';   # Test::More work-alike for Perl 5.8.0
} else {
    require Test::More;
}
Test::More->import();
plan('tests' => 37);

# Regular array
my @ary1 = qw/foo bar baz/;
push(@ary1, [ 1..3 ], { 'qux' => 99 });

# Shared array
my @ary2 :shared = (99, 21, 86);

# Regular hash-based object
my $obj1 = {
    'foo' => 'bar',
    'qux' => 99,
    'biff' => [ qw/fee fi fo/ ],
    'boff' => { 'bork' => 'true' },
};
bless($obj1, 'Foo');

# Shared hash-based object
my $obj2 = &share({});
$$obj2{'bar'} = 86;
$$obj2{'key'} = 'foo';
bless($obj2, 'Bar');

# Scalar ref
my $sref1 = \do{ my $scalar = 'foo'; };

# Shared scalar ref object
my $sref2 = \do{ my $scalar = 69; };
share($sref2);
bless($sref2, 'Baz');

# Queue up items
my $q = Thread::Queue->new(\@ary1, \@ary2);
ok($q, 'New queue');
is($q->pending(), 2, 'Queue count');
$q->enqueue($obj1, $obj2);
is($q->pending(), 4, 'Queue count');
$q->enqueue($sref1, $sref2);
is($q->pending(), 6, 'Queue count');

# Process items in thread
threads->create(sub {
    is($q->pending(), 6, 'Queue count in thread');

    my $tary1 = $q->dequeue();
    ok($tary1, 'Thread got item');
    is(ref($tary1), 'ARRAY', 'Item is array ref');
    is_deeply($tary1, \@ary1, 'Complex array');
    $$tary1[1] = 123;

    my $tary2 = $q->dequeue();
    ok($tary2, 'Thread got item');
    is(ref($tary2), 'ARRAY', 'Item is array ref');
    for (my $ii=0; $ii < @ary2; $ii++) {
        is($$tary2[$ii], $ary2[$ii], 'Shared array element check');
    }
    $$tary2[1] = 444;

    my $tobj1 = $q->dequeue();
    ok($tobj1, 'Thread got item');
    is(ref($tobj1), 'Foo', 'Item is object');
    is_deeply($tobj1, $obj1, 'Object comparison');
    $$tobj1{'foo'} = '.|.';
    $$tobj1{'smiley'} = ':)';

    my $tobj2 = $q->dequeue();
    ok($tobj2, 'Thread got item');
    is(ref($tobj2), 'Bar', 'Item is object');
    is($$tobj2{'bar'}, 86, 'Shared object element check');
    is($$tobj2{'key'}, 'foo', 'Shared object element check');
    $$tobj2{'tick'} = 'tock';
    $$tobj2{'frowny'} = ':(';

    my $tsref1 = $q->dequeue();
    ok($tsref1, 'Thread got item');
    is(ref($tsref1), 'SCALAR', 'Item is scalar ref');
    is($$tsref1, 'foo', 'Scalar ref contents');
    $$tsref1 = 0;

    my $tsref2 = $q->dequeue();
    ok($tsref2, 'Thread got item');
    is(ref($tsref2), 'Baz', 'Item is object');
    is($$tsref2, 69, 'Shared scalar ref contents');
    $$tsref2 = 'zzz';

    is($q->pending(), 0, 'Empty queue');
    my $nothing = $q->dequeue_nb();
    ok(! defined($nothing), 'Nothing on queue');
})->join();

# Check results of thread's activities
is($q->pending(), 0, 'Empty queue');

is($ary1[1], 'bar', 'Array unchanged');
is($ary2[1], 444, 'Shared array changed');

is($$obj1{'foo'}, 'bar', 'Object unchanged');
ok(! exists($$obj1{'smiley'}), 'Object unchanged');

is($$obj2{'tick'}, 'tock', 'Shared object changed');
is($$obj2{'frowny'}, ':(', 'Shared object changed');

is($$sref1, 'foo', 'Scalar ref unchanged');
is($$sref2, 'zzz', 'Shared scalar ref changed');

# EOF
