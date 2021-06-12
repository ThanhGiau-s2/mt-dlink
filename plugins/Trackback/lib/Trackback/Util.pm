# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback::Util;

use strict;
use warnings;
use base 'Exporter';
use MT::Util qw( decode_xml first_n_words );
use MT::I18N qw( const );

our @EXPORT_OK = qw( discover_tb );

sub discover_tb {
    my ( $url, $find_all, $contents ) = @_;
    my $c = '';
    if ($contents) {
        $c = $$contents;
    }
    else {
        my $ua = MT->new_ua;
        ## Wrap this in an eval in case some versions don't support it.
        my $req = HTTP::Request->new( GET => $url );
        eval {
            $ua->timeout(30);    # limit timeout to 30 seconds
            $ua->parse_head(0);
        };

        # prevent downloads of non-text content
        my $res = $ua->request(
            $req,
            sub {
                my ( $data, $res, $po ) = @_;
                die
                    unless $c ne ''
                    or $res->header('Content-Type') =~ m!^text/!;
                $c .= $data;
            },
            16384
        );
        return unless $res->is_success;
    }
    ( my $url_no_anchor = $url ) =~ s/#.*$//;
    ( my $url_no_host   = $url_no_anchor ) =~ s!^https?://.*/!!i;
    my (@items);
    while ( $c =~ m!(<rdf:RDF.*?</rdf:RDF>)!sg ) {
        my $rdf = $1;
        my ($perm_url) = $rdf =~ m!dc:identifier="([^"]+)"!;    #"
        $perm_url ||= "";
        ( my $perm_url_no_host = $perm_url ) =~ s!https?://.*/!!i;
        $perm_url_no_host =~ s/#.*$//;
        next
            unless $find_all
            || $perm_url eq $url
            || $perm_url eq $url_no_anchor
            || $perm_url_no_host eq $url_no_host;
        ( my $inner = $rdf ) =~ s!^.*?<rdf:Description!!s;
        my $item = { permalink => $perm_url };

        while ( $inner =~ /([\w:]+)="([^"]*)"/gs ) {    #"
            $item->{$1} = $2;
        }
        $item->{ping_url} = $item->{'trackback:ping'};
        next unless $item->{ping_url};
        $item->{title} = decode_xml( $item->{'dc:title'} );
        if ( !$item->{title} && $rdf =~ m!dc:description="([^"]+)"! ) {    #"
            $item->{title}
                = first_n_words( $1, const('LENGTH_ENTRY_TITLE_FROM_TEXT') )
                . '...';
        }
        push @items, $item;
        last unless $find_all;
    }
    return unless @items;
    $find_all ? \@items : $items[0];
}

1;
