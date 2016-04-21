use strict;
use warnings;

use Test::More;
use Config;
if ($Config{'useithreads'}) {
    plan 'tests' => 1;
} else {
    plan 'skip_all' => q/Perl not compiled with 'useithreads'/;
}

use_ok('Thread::Queue');
if ($Thread::Queue::VERSION) {
    diag('Testing Thread::Queue ' . $Thread::Queue::VERSION);
}

# EOF
