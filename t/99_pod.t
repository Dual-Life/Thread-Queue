use strict;
use warnings;

BEGIN {
    if (! $ENV{RUN_MAINTAINER_TESTS}) {
        print("1..0 # Skip: Module maintainer tests\n");
        exit(0);
    }

    eval {
        require Test::More;
        Test::More->import('tests' => 3);
    };
    if ($@) {
        print("1..0 # Skip: Test::More not available\n");
        exit(0);
    }
}

SKIP: {
    eval 'use Test::Pod 1.26';
    skip('Test::Pod 1.26 required for testing POD', 1) if $@;

    pod_file_ok('lib/Thread/Queue.pm');
}

SKIP: {
    eval 'use Test::Pod::Coverage 1.08';
    skip('Test::Pod::Coverage 1.08 required for testing POD coverage', 1) if $@;

    pod_coverage_ok('Thread::Queue',
                    {
                        'trustme' => [
                        ],
                        'private' => [
                            '_make_shared',
                        ]
                    }
    );
}

SKIP: {
    eval "use Test::Spelling";
    skip("Test::Spelling required for testing POD spelling", 1) if $@;
    if (system('aspell help >/dev/null 2>&1')) {
        skip("'aspell' required for testing POD spelling", 1);
    }
    set_spell_cmd('aspell list --lang=en');
    add_stopwords(<DATA>);
    pod_file_spelling_ok('lib/Thread/Queue.pm', 'POD spelling');
    unlink("/home/$ENV{'USER'}/en.prepl", "/home/$ENV{'USER'}/en.pws");
}

__DATA__

Hedden
cpan
readonly
baz
pre-populated

__END__
