# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback::CMS::Category;

use strict;
use warnings;
use MT::Util qw( encode_url );

sub _edit {
    my ( $app, $blog, $obj, $param ) = @_;

    require MT::Trackback;
    my $tb = MT::Trackback->load( { category_id => $obj->id } ) or return;

    my $list_pref = $app->list_pref('ping');
    %$param = ( %$param, %$list_pref );
    my $path = $app->config('CGIPath');
    $path .= '/' unless $path =~ m!/$!;
    if ( $path =~ m!^/! ) {
        my ($blog_domain) = $blog->archive_url =~ m|(.+://[^/]+)|;
        $path = $blog_domain . $path;
    }

    my $script = $app->config('TrackbackScript');
    $param->{tb}     = 1;
    $param->{tb_url} = $path . $script . '/' . $tb->id;
    if ( $param->{tb_passphrase} = $tb->passphrase ) {
        $param->{tb_url}
            .= '/' . encode_url( $param->{tb_passphrase} );
    }
    $app->load_list_actions( 'ping', $param->{ping_table}[0], 'pings' );
}

1;
