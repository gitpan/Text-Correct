# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Text::Correct qw( wrap );
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$Text::Correct::MAX_LEN = 25;
$Text::Correct::PARA = 0;

print "1234567890123456789012345\n";
print $output = wrap "\t", "", << "END OF TEXT";
This is going to be formatted
in a certain
  way when
THIS IS all


done!

you'll see!
END OF TEXT

print $output eq << "END OF TEXT" ? "ok 2\n" : "not ok 2\n";
	This is going to
be formatted in a
certain way when THIS IS
all done!  you'll see!
END OF TEXT