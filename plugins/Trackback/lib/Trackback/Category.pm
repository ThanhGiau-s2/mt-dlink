# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback::Category;

use strict;
use warnings;

sub _save_trackback {
    my $cat = shift;

    require MT::Trackback;
    if ( $cat->allow_pings ) {
        my $tb;
        unless ( $tb = MT::Trackback->load( { category_id => $cat->id } ) ) {
            $tb = MT::Trackback->new;
            $tb->blog_id( $cat->blog_id );
            $tb->category_id( $cat->id );
            $tb->entry_id(0);    ## entry_id can't be NULL
        }
        if ( defined( my $pass = $cat->{__tb_passphrase} ) ) {
            $tb->passphrase($pass);
        }
        $tb->title( $cat->label );
        $tb->description( $cat->description );
        my $blog = MT::Blog->load( $cat->blog_id )
            or return;
        my $url = $blog->archive_url;
        $url .= '/' unless $url =~ m!/$!;
        $url .= MT::Util::archive_file_for( undef, $blog, 'Category', $cat );
        $tb->url($url);
        $tb->is_disabled(0);
        $tb->save
            or return $cat->error( $tb->errstr );
    }
    else {
        ## If there is a TrackBack item for this category, but
        ## pings are now disabled, make sure that we mark the
        ## object as disabled.
        if ( my $tb = MT::Trackback->load( { category_id => $cat->id } ) ) {
            $tb->is_disabled(1);
            $tb->save
                or return $cat->error( $tb->errstr );
        }
    }
    return 1;
}

1;
