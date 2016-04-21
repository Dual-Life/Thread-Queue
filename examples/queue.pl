#!/usr/bin/env perl

use strict;
use warnings;

use threads;
use Thread::Queue;

# Create a work queue for sending data to a 'worker' thread
#   Prepopulate it with a few work items
my $work_q = Thread::Queue->new(qw/foo bar baz/);

# Create a status queue to get reports from the thread
my $status_q = Thread::Queue->new();

# Create a detached thread to process items from the queue
threads->create(sub {
                    # Keep grabbing items off the work queue
                    while (my $item = $work_q->dequeue()) {
                        # Thread is being told to exit
                        last if ($item eq 'exit');

                        # Process the item from the queue
                        print("Thread got '$item'\n");

                        # Ask for more work when the queue is empty
                        if (! $work_q->pending()) {
                            print("\nThread waiting for more work\n\n");
                            $status_q->enqueue('more');
                        }
                    }

                    # Final report
                    print("Thread done\n");
                    $status_q->enqueue('done');

                })->detach();

# More work for the thread
my @work = (
    [ 'bippity', 'boppity', 'boo' ],
    [ 'ping', 'pong' ],
    [ 'exit' ],             # Will terminate the thread
);

# Send work to the thread
while ($status_q->dequeue() eq 'more') {
    $work_q->enqueue(@{shift(@work)});
}

# EOF
