package Text::Correct;

use strict;
use vars qw( @ISA @EXPORT_OK $VERSION $MAX_LEN $PARA $TAB );

require Exporter;

@ISA = qw( Exporter );
@EXPORT_OK = qw(
	wrap
	$MAX_LEN $PARA $TAB
);

$VERSION = '0.02';

$MAX_LEN = 72;
$PARA = 1;
$TAB = 8;


sub wrap {
	my ($init,$pre) = (shift,shift);
	my ($flag,$line) = (1,"");
	my ($tmp,@ret);
	local $_;

	if ($PARA) {
		local $PARA = 0;
		@_ = split /\n{2,}/, join "", @_;
		for (@_) { push @ret, wrap($init,$pre,split /\n/), "\n" }
		pop @ret;
		return wantarray ? @ret : join "", @ret;
	}
	else { @_ = split /\n+/, join "", map "$_\n", @_ }

	for $tmp (@_) {
		chomp($_ = $tmp);
		s/^\s+//;
		($_,$flag) = ("$init$_",0) if $flag;

		if (substr($line, -1) =~ /[,;\w](?:["'])?$/ and /^\w/) { $line .= " " }
		elsif (substr($line, -1) =~ /[.!?)](?:["'])?$/ and /^\w/) { $line .= "  " }
		$line = expand($line .= $_);

		while (length $line > $MAX_LEN) {
			(my $sub = substr($line, 0, $MAX_LEN+1)) =~ /[$:](?=[^$:]*$)/g;
			pos($sub) = $MAX_LEN if !defined(pos($sub));
			(my $str = substr($sub, 0, pos($sub))) =~ s/\s+$//;
			push @ret, unexpand("$str\n");
			($line = substr($line, pos($sub))) =~ s/^\s+//;
			$line = "$pre$line";
		}
	}

	push @ret, "$line\n" if $line;
	return wantarray ? @ret : join "", @ret;
}


sub expand {
	local $_ = $_[0];
	while (/(?=(\t+))/g){
		substr($_,pos,length($1),
			"\0" x ($TAB * length($1) - (pos() % $TAB))
		);
	}

	return $_;
}


sub unexpand {
	(local $_ = $_[0]) =~ s/( \0 {1,$TAB} )/\t/xg;
	return $_;
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

=item expand(TEXT)

This converts tabs to NULL characters.  This function is used internally,
but is governed by the $TAB variable.

=item unexpand(TEXT)

This converts series of NULL characters to tabs.  This function is used
internally, but is governed by the $TAB variable.

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

=item $Text::Correct::TAB

This holds the number of spaces a tab is to represent.  It defaults to 8,
and is used in determining the length of a string with tabs in it.

=back

=head1 COMING SOON

I plan to reimplement this module using formline().

=head1 BUGS

If text contains NULL characters, expand() and unexpand() will not work
properly.  Fix:  don't use NULL characters. ;)

=head1 AUTHOR

Jeff Pinyan, japhy+perl@pobox.com, CPAN ID: PINYAN

=head1 SEE ALSO

  Text::Wrap
  Text::Tabs

=cut
