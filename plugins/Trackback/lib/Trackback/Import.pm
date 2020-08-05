# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback::Import;

use strict;
use warnings;
use MT::Util qw( encode_html );

sub _ping_to_import {
    my ( $piece, $blog_id ) = @_;
    ## Pings are: TITLE, URL, IP, DATE, BLOG NAME,
    ## then excerpt
    require MT::TBPing;
    my $ping = MT::TBPing->new;
    $ping->blog_id($blog_id);
    my @lines = split /\r?\n/, $piece;
    my ( $i, $body_idx ) = (0) x 2;
PING:
    for my $line (@lines) {
        $line =~ s!^\s*!!;
        my ( $key, $val ) = split /\s*:\s*/, $line, 2;
        if ( $key eq 'TITLE' ) {
            $ping->title($val);
        }
        elsif ( $key eq 'URL' ) {
            $ping->source_url($val);
        }
        elsif ( $key eq 'IP' ) {
            $ping->ip($val);
        }
        elsif ( $key eq 'DATE' ) {
            if ( my $date = MT::ImportExport->_convert_date($val) ) {
                $ping->created_on($date);
            }
        }
        elsif ( $key eq 'BLOG NAME' ) {
            $ping->blog_name($val);
        }
        else {
            ## Now we have reached the ping excerpt;
            ## everything from here until the end of the
            ## array is body.
            $body_idx = $i;
            last PING;
        }
        $i++;
    }
    $ping->excerpt( join "\n", @lines[ $body_idx .. $#lines ] );
    $ping->approve;
    return $ping;
}

sub _save_pings {
    my ( $cb, $entry, $pings ) = @_;

    if (@$pings) {
        my $tb;
        unless ( $tb = $entry->trackback ) {
            $tb = MT->model('trackback')->new;
            $tb->blog_id( $entry->blog_id );
            $tb->entry_id( $entry->id );
            $tb->category_id(0);    ## category_id can't be NULL
            $tb->title( $entry->title );
            $tb->description( $entry->get_excerpt );
            $tb->url( $entry->permalink );
            $tb->is_disabled(0);
            $tb->save
                or return MT::ImportExport->error( $tb->errstr );
            $entry->trackback($tb);
        }

        for my $ping (@$pings) {
            $ping->tb_id( $tb->id );
            $cb->(
                MT->translate(
                    "Creating new ping ('[_1]')...",
                    encode_html( $ping->title )
                )
            );
            if ( $ping->save ) {
                $cb->( MT->translate( "ok (ID [_1])", $ping->id ) . "\n" );
            }
            else {
                $cb->( MT->translate("failed") . "\n" );
                return MT::ImportExport->error(
                    MT->translate(
                        "Saving ping failed: [_1]", $ping->errstr
                    )
                );
            }
        }
    }
}

1;
