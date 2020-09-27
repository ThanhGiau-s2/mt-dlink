package MIME::Types;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK);

require Exporter;

@ISA = qw(Exporter);
@EXPORT_OK = qw(by_suffix by_mediatype import_mime_types);

$VERSION = '0.06';

my $_table = {
	      ai => ['application/postscript', '8bit'],
	      aiff => ['audio/x-aiff', 'base64'],
	      au => ['audio/basic', 'base64'],
	      avi => ['video/x-msvideo', 'base64'],
	      bck => ['application/VMSBACKUP', 'base64'],
	      bin => ['application/x-octetstream', 'base64'],
	      bleep => ['application/bleeper', '8bit'],
	      class => ['application/octet-stream', 'base64'],
	      com => ['text/plain', '8bit'],
	      crt => ['application/x-x509-ca-cert', 'base64'],
	      csh => ['application/x-csh', 'base64'],
	      dat => ['text/plain', '8bit'],
	      doc => ['application/msword', 'base64'],
	      dot => ['application/msword', 'base64'],
	      dvi => ['application/x-dvi', 'base64'],
	      eps => ['application/postscript', '8bit'],
	      exe => ['application/octet-stream', 'base64'],
	      gif => ['image/gif', 'base64'],
	      gtar => ['application/x-gtar', 'base64'],
	      gz => ['application/x-gzip', 'base64'],
	      hlp => ['text/plain', '8bit'],
	      hqx => ['application/mac-binhex40', 'base64'],
	      htm => ['text/html', '8bit'],
	      html => ['text/html', '8bit'],
	      htmlx => ['text/html', '8bit'],
	      htx => ['text/html', '8bit'],
	      imagemap => ['application/imagemap', '8bit'],
	      jpe => ['image/jpeg', 'base64'],
	      jpeg => ['image/jpeg', 'base64'],
	      jpg => ['image/jpeg', 'base64'],
	      mcd => ['application/mathcad', 'base64'],
	      mid => ['audio/midi', 'base64'],
	      midi => ['audio/midi', 'base64'],
	      mov => ['video/quicktime', 'base64'],
	      movie => ['video/x-sgi-movie', 'base64'],
	      mpeg => ['video/mpeg', 'base64'],
	      mpe => ['video/mpeg', 'base64'],
	      mpg => ['video/mpeg', 'base64'],
	      pdf => ['application/pdf', 'base64'],
	      ppt => ['application/vnd.ms-powerpoint', 'base64'],
	      ps => ['application/postscript', '8bit'],
	      'ps-z' => ['application/postscript', 'base64'],
	      qt => ['video/quicktime', 'base64'],
	      # Look out!
#	      rtf => ['text/richtext', '8bit'],
	      rtf => ['application/rtf', '8bit'],
	      #
	      rtx => ['text/richtext', '8bit'],
	      sh => ['application/x-sh', 'base64'],
	      sit => ['application/x-stuffit', 'base64'],
	      tar => ['application/x-tar', 'base64'],
	      tif => ['image/tiff', 'base64'],
	      tiff => ['image/tiff', 'base64'],
	      txt => ['text/plain', '8bit'],
	      ua => ['audio/basic', 'base64'],
	      wav => ['audio/x-wav', 'base64'],
	      xls => ['application/vnd.ms-excel', 'base64'],
	      xbm => ['image/x-xbitmap', '7bit'],
	      zip => ['application/zip', 'base64'],
	     };

{
    # Lifted from CGI.pm. Some systems support the $^O variable. If not
    # available then require() the Config library
    my $os;
    unless ($os = $^O) {
	require Config;
	$os = $Config::Config{osname};
    }

    if ($os =~ /Mac/i) {
	# It's a Mac. Change the relevant MIME type.
	$_table->{bin} = ['application/x-macbase64'];
    } elsif ($os =~ /vms/i) {
	# It's VMS. Change the relevant MIME type.
	$_table->{doc} = ['text/plain', '8bit'];
    }
}

sub by_suffix {
    my $arg = shift || return;

    # Look for a suffix on the file name. If there isn't one, assume the
    # argument is the suffix itself.
    my $suffix = substr $arg, rindex($arg, '.') + 1;

    # Get the MIME type and return it or an empty list.
    my $rv = $_table->{ lc $suffix } || return;
    return wantarray ? @$rv : $rv;
}

sub by_mediatype {
    my $type = lc shift || return;
    # If there's a slash, we'll do a direct comparison. Otherwise, we'll do a
    # regular expression.
    my $comp = index($type, '/') != -1 ? 1 : 0;

    my @rv;
    while (my ($key, $aref) = each %$_table) {
	# Grab each one that applies.
	push(@rv, [$key, $aref->[0], $aref->[1]])
	  # And do either a direct comparison or a regular expression.
	  if $comp ? $aref->[0] eq $type : $aref->[0] =~ /$type/;
    }
    return wantarray ? @rv : \@rv;
}

sub import_mime_types {
    my $mimefile = shift || return;
    my($type, @exts, $enc, $num, $ext);

    local *MIMEFILE;
    local $_;

    open(MIMEFILE, $mimefile) || die "Can't open mime.types file: $!\n";

    while(<MIMEFILE>) {
      chomp;
      next if m/^\s*#/;
      next if m/^\s*$/;
      ($type, @exts) = split;
      if ($type =~ m|^text\/|) {
        $enc = "quoted-printable";
      } else {
        $enc = "base64";
      }
      foreach $ext (@exts) {
        if (! defined($_table->{$ext})) {
	  $num++;
	  $_table->{$ext} = [$type, $enc];
	}
      }
    }
    close(MIMEFILE);
    return $num;
}


1;
__END__

=head1 NAME

MIME::Types - Perl extension for determining MIME types and Transfer Encoding

=head1 SYNOPSIS

  use MIME::Types qw(by_suffix by_mediatype import_mime_types);

  import_mime_types("/www/mime.types");

  my ($mime_type, $encoding) = by_suffix(FILENAME);
  my $aref = by_suffix(FILENAME);

  my @list = by_mediatype(MEDIATYPE);
  my $aref = by_mediatype(MEDIATYPE);

=head1 DESCRIPTION

NOTE: This is ALPHA code. There are no guarantees that any of the subroutines
described here will not have their names or return values changed.

This module is built to conform to the MIME types standard defined in RFC 1341
and updated by RFC's 1521 and 1522. It follows the collection kept at
F<http://www.ltsw.se/knbase/internet/mime.htp>.

=head1 INTERFACE

The following functions are avilable:

=over 4

=item B<by_suffix>

This function takes either a file name suffix or a complete file name.
It returns a two-element list or an anonymous array if the suffix can be found:
the media type and a content encoding.
An empty list is returned if the suffix could not be found.

=item B<by_mediatype>

This function takes a media type and returns a list or anonymous array of
anonymous three-element arrays whose values are the file name suffix used to
identify it, the media type, and a content encoding.

If the media type contains a slash (/),
it is assumed to be a complete media type
and must exactly match against the internal table.
Otherwise the value is compared to all the values in the table
via a regular expression.
All regular expression codes are supported
(except, of course, any string with a slash in it).
Thus, calling B<by_mediatype("application")> will return a large list.

=item B<import_mime_types>

This function takes a filename as argument and returns the number
of filename extensions imported. The file should be similar in format
to the mime.types file distributed with the Apache webserver. Each
MIME type should be at the start of a line followed by whitespace
separated extensions (without the "."). For example:

text/tab-separated-values    tab tsv

If an extension in the mime.types file conflicts with an extension
built into the MIME::Types package, it will be ignored. The encoding
assigned to each type is "quoted-printable" for "text/*" types and
"base64" for everything else.

=back

=head1 AUTHOR

Jeff Okamoto <F<okamoto@corp.hp.com>>.

Updated by David Wheeler <F<david@wheeler.net>>.

B<import_mime_types> added by Mike Cramer <F<cramer@webkist.com>>
with fixes by Antonios Christofides <F<A.Christofides@hydro.ntua.gr>>.

Inspired by the mail_attach.pl program by
Dan Sugalski <F<dan@sidhe.org>>.

=cut
