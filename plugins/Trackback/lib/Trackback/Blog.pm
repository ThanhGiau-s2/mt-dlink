# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id:

package Trackback::Blog;

use strict;
use warnings;

sub _clone_trackbacks {
    my ( $callback, $old_blog_id, $new_blog_id, $extra ) = @_;

    my $entry_map = $extra->{entry};
    my $cat_map   = $extra->{category};
    my $tb_map    = $extra->{trackback};

    my $state = MT->translate("Cloning TrackBacks for blog...");
    $callback->( $state, "tbs" );
    require MT::Trackback;
    my $iter = MT::Trackback->load_iter( { blog_id => $old_blog_id } );
    my $counter = 0;
    while ( my $tb = $iter->() ) {
        next
            unless ( $tb->entry_id && $entry_map->{ $tb->entry_id } )
            || ( $tb->category_id && $cat_map->{ $tb->category_id } );

        $callback->(
            $state . " "
                . MT->translate( "[_1] records processed...", $counter ),
            'tbs'
        ) if $counter && ( $counter % 100 == 0 );
        $counter++;
        my $tb_id  = $tb->id;
        my $new_tb = $tb->clone();
        delete $new_tb->{column_values}->{id};
        delete $new_tb->{changed_cols}->{id};

        if ( $tb->category_id ) {
            if ( my $cid = $cat_map->{ $tb->category_id } ) {
                my $cat_tb = MT::Trackback->load( { category_id => $cid } );
                if ($cat_tb) {
                    my $changed;
                    if ( $tb->passphrase ) {
                        $cat_tb->passphrase( $tb->passphrase );
                        $changed = 1;
                    }
                    if ( $tb->is_disabled ) {
                        $cat_tb->is_disabled(1);
                        $changed = 1;
                    }
                    $cat_tb->save if $changed;
                    $tb_map->{$tb_id} = $cat_tb->id;
                    next;
                }
            }
        }
        elsif ( $tb->entry_id ) {
            if ( my $eid = $entry_map->{ $tb->entry_id } ) {
                my $entry_tb = MT::Entry->load($eid)->trackback;
                if ($entry_tb) {
                    my $changed;
                    if ( $tb->passphrase ) {
                        $entry_tb->passphrase( $tb->passphrase );
                        $changed = 1;
                    }
                    if ( $tb->is_disabled ) {
                        $entry_tb->is_disabled(1);
                        $changed = 1;
                    }
                    $entry_tb->save if $changed;
                    $tb_map->{$tb_id} = $entry_tb->id;
                    next;
                }
            }
        }

        # A trackback wasn't created when saving the entry/category,
        # (perhaps trackbacks are now disabled for the entry/category?)
        # so create one now
        $new_tb->entry_id( $entry_map->{ $tb->entry_id } )
            if $tb->entry_id && $entry_map->{ $tb->entry_id };
        $new_tb->category_id( $cat_map->{ $tb->category_id } )
            if $tb->category_id && $cat_map->{ $tb->category_id };
        $new_tb->blog_id($new_blog_id);
        $new_tb->save or die $new_tb->errstr;
        $tb_map->{$tb_id} = $new_tb->id;
    }
    $callback->(
        $state . " " . MT->translate( "[_1] records processed.", $counter ),
        'tbs'
    );
}

sub _clone_pings {
    my ( $callback, $old_blog_id, $new_blog_id, $extra ) = @_;

    my $entry_map = $extra->{entry};
    my $cat_map   = $extra->{category};
    my $tb_map    = $extra->{trackback};

    my $state = MT->translate("Cloning TrackBack pings for blog...");
    $callback->( $state, "pings" );
    require MT::TBPing;
    my $iter = MT::TBPing->load_iter( { blog_id => $old_blog_id } );
    my $counter = 0;
    while ( my $ping = $iter->() ) {
        next unless $tb_map->{ $ping->tb_id };
        $callback->(
            $state . " "
                . MT->translate( "[_1] records processed...", $counter ),
            'pings'
        ) if $counter && ( $counter % 100 == 0 );
        $counter++;
        my $new_ping = $ping->clone();
        delete $new_ping->{column_values}->{id};
        delete $new_ping->{changed_cols}->{id};
        $new_ping->tb_id( $tb_map->{ $ping->tb_id } );
        $new_ping->blog_id($new_blog_id);
        $new_ping->save or die $new_ping->errstr;
    }
    $callback->(
        $state . " " . MT->translate( "[_1] records processed.", $counter ),
        'pings'
    );
}

1;
