package Text::Correct;

use strict;
use vars qw( @ISA @EXPORT_OK $VERSION $MAX_LEN $PARA );

require Exporter;

@ISA = qw( Exporter );
@EXPORT_OK = qw( wrap $MAX_LEN $PARA );

$VERSION = '0.01';

$MAX_LEN = 72;
$PARA = 1;


sub wrap {
	my ($init,$pre) = (shift,shift);
	my ($flag,$line) = (1,"");
	my ($tmp,@ret);
	local $_;

	if ($PARA) {
		local $PARA = 0;
		@_ = split /\n{2,}/, join "", @_;
		for (@_) { push @ret, wrap($init,$pre,split /\n/, $_), "\n" }
		pop @ret;
		return wantarray ? @ret : join "", @ret;
	}
	else { @_ = split /\n/, join "", @_ }

	for $tmp (@_) {
		$_ = $tmp;
		chomp;
		s/^[>\s]+//;
		($_,$flag) = ("$init$_",0) if $flag;

		if (substr($line, -1) =~ /[,;\w](?:["'])?$/ and /^\w/) { $line .= " " }
		elsif (substr($line, -1) =~ /[.!?)](?:["'])?$/ and /^\w/) { $line .= "  " }
		$line .= $_;

		while (length $line > $MAX_LEN) {
			(my $sub = substr($line, 0, $MAX_LEN)) =~ /[$:](?=[^$:]*$)/g;
			pos($sub) = length $sub if !defined(pos($sub));
			(my $str = substr($sub, 0, pos($sub))) =~ s/\s+$//;
			push @ret, "$str\n";
			($line = substr($line, pos($sub))) =~ s/^\s+//;
			$line = "$pre$line";
		}
	}

	push @ret, "$line\n" if $line;
	return wantarray ? @ret : join "", @ret;
}


1;

__END__

=head1 NAME

Text::Correct - Module for implementing text wrapping

=head1 SYNOPSIS

    use Text::Correct qw( wrap $MAX_LEN $PARA );
    $MAX_LEN = 60;  # 60 columns of text
    $PARA = 0;      # condense newlines
    print wrap($firstline_lead, $otherline_lead, @text);

    use Text::Correct qw( wrap );
    wrap("\t", "", $speech);  # "regular" paragraph formatting    

=head1 DESCRIPTION

This module is sort of a different approach to text wrapping than taken in
Text::Wrap.  This module allows for condensing of newlines, to format long
blocks of text into one, or (as the default) to format paragraphs (these are
blocks of text separated by two or more newlines) individually.

=head2 Functions

=over 4

=item wrap(INITAL_LEAD, SUBSEQUENT_LEAD, TEXT)

The first argument is the lead to be placed in front of the first line; the
second is the lead to be placed in front of each subsequent line.  Following
that is a list of lines of text.  The function is not exported by default.

=back

=head2 Variables

=over 4

=item $Text::Correct::MAX_LEN

The number of characters of text (excluding a newline) per line.

=item $Text::Correct::PARA

A boolean deciding whether or not to invoke paragraph mode.  If paragraph
mode is on, text will be split up into blocks separated by two or more
newlines.  If it is off, the text will be treated as a single block, which
means the text is condensed into one paragraph.

=back

=head1 COMING SOON

I plan to reimplement this module using formline().

=head1 AUTHOR

Jeff Pinyan, japhy+perl@pobox.com, CPAN ID: PINYAN

=head1 SEE ALSO

  Text::Wrap

=cut
