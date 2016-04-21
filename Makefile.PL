# Module makefile for Thread::Queue (using ExtUtils::MakeMaker)

use Config;
BEGIN {
    if (! $Config{'useithreads'} || ($] < 5.008)) {
        die("ERROR:  This Perl not built to support threads\n");
    }
}

use ExtUtils::MakeMaker;

# Construct make file
WriteMakefile(
    'NAME'          => 'Thread::Queue',
    'AUTHOR'        => 'Jerry D. Hedden <jdhedden AT cpan DOT org>',
    'VERSION_FROM'  => 'lib/Thread/Queue.pm',
    'ABSTRACT_FROM' => 'lib/Thread/Queue.pm',
    'PREREQ_PM'     => {
        'threads'         => 0,
        'threads::shared' => 0.96,
        'Scalar::Util'    => 1.10,
        'Test::More'      => 0.50,
    },

    ((ExtUtils::MakeMaker->VERSION() lt '6.25') ?
        ('PL_FILES' => { })            : ()),
    ((ExtUtils::MakeMaker->VERSION() gt '6.30') ?
        ('LICENSE'  => 'perl')         : ()),
);

# EOF
